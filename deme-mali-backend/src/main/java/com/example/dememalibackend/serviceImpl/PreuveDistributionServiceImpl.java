
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.Enum.TypeMedia;
import com.example.dememalibackend.dto.PreuveDistributionRequestDTO;
import com.example.dememalibackend.dto.PreuveDistributionResponseDTO;
import com.example.dememalibackend.entity.AideDistribuee;
import com.example.dememalibackend.entity.PreuveDistribution;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.mappers.PreuveDistributionMapper;
import com.example.dememalibackend.repository.AideDistribueeRepository;
import com.example.dememalibackend.repository.PreuveDistributionRepository;
import com.example.dememalibackend.service.PreuveDistributionService;

import lombok.RequiredArgsConstructor;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class PreuveDistributionServiceImpl
        implements PreuveDistributionService {

    private final PreuveDistributionRepository preuveRepository;
    private final AideDistribueeRepository aideDistribueeRepository;
    private final CustomUserDetailsService customUserDetailsService;
    private final DemandeAideVisibilite demandeAideVisibilite;

    private final String dossierUpload = "uploads/distributions";

    // Limites de taille : 100 Mo pour les images et documents,
    // 200 Mo pour les vidéos.
    private static final long TAILLE_MAX_IMAGE_DOCUMENT =
            100L * 1024 * 1024;

    private static final long TAILLE_MAX_VIDEO =
            200L * 1024 * 1024;

    private static final String PREFIXE_URL =
            "/uploads/distributions/";

    /**
     * Vérifier si une distribution appartient à une organisation.
     */
    private boolean appartientAUneOrganisation(AideDistribuee aide) {

        boolean lieeParDemande =
                aide.getDemandeAide() != null
                && aide.getDemandeAide().getOrganisationPartenaire() != null;

        boolean lieeParBeneficiaire =
                aide.getBeneficiaire() != null
                && aide.getBeneficiaire().getOrganisationPartenaire() != null;

        return lieeParDemande || lieeParBeneficiaire;
    }

    /**
     * Vérifier les droits de consultation d'une distribution.
     */
    private void verifierDroitConsultation(AideDistribuee aide) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        RoleEnum role = utilisateur.getRole();

        // ADMIN : accès à toutes les distributions.
        if (role == RoleEnum.ADMIN) {
            return;
        }

        // DONATEUR : accès aux distributions des organisations,
        // même s'il n'a pas contribué à chaque demande.
        if (role == RoleEnum.DONATEUR) {

            if (!appartientAUneOrganisation(aide)) {
                throw new AccessDeniedException(
                        "Cette distribution n'est pas associée à une organisation."
                );
            }

            return;
        }

        // ORGANISATIONPARTENAIRE : uniquement ses distributions.
        if (role == RoleEnum.ORGANISATIONPARTENAIRE) {
            verifierOrganisationConnectee(aide);
            return;
        }

        // Bénéficiaire : ses distributions ou celles d'une demande publiée.
        if (role == RoleEnum.BENEFICIARE) {

            boolean estBeneficiaire =
                    aide.getBeneficiaire() != null
                    && Objects.equals(
                            aide.getBeneficiaire().getId(),
                            utilisateur.getId()
                    );

            if (!estBeneficiaire
                    && !demandeAideVisibilite.estValideeAvecEtudeTerminee(aide.getDemandeAide())) {
                throw new AccessDeniedException(
                        "Vous n'avez pas le droit de consulter cette distribution."
                );
            }

            return;
        }

        throw new AccessDeniedException(
                "Vous n'avez pas le droit de consulter ces preuves."
        );
    }

    /**
     * Vérifier que l'organisation connectée est propriétaire
     * de la distribution.
     */
    private void verifierOrganisationConnectee(AideDistribuee aide) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur.getRole() != RoleEnum.ORGANISATIONPARTENAIRE) {
            throw new AccessDeniedException(
                    "Seule une organisation peut effectuer cette opération."
            );
        }

        boolean estProprietaire = false;

        // Distribution liée à une demande d'aide.
        if (aide.getDemandeAide() != null
                && aide.getDemandeAide().getOrganisationPartenaire() != null) {

            estProprietaire = Objects.equals(
                    aide.getDemandeAide()
                            .getOrganisationPartenaire()
                            .getId(),
                    utilisateur.getId()
            );
        }

        // Distribution directement liée à un bénéficiaire.
        if (aide.getBeneficiaire() != null
                && aide.getBeneficiaire().getOrganisationPartenaire() != null) {

            estProprietaire = estProprietaire || Objects.equals(
                    aide.getBeneficiaire()
                            .getOrganisationPartenaire()
                            .getId(),
                    utilisateur.getId()
            );
        }

        if (!estProprietaire) {
            throw new AccessDeniedException(
                    "Vous ne pouvez pas gérer les preuves de cette organisation."
            );
        }
    }

    /**
     * Ajouter une preuve à partir de ses informations.
     */
    @Override
    public PreuveDistributionResponseDTO ajouter(
            Integer aideDistribueeId,
            PreuveDistributionRequestDTO dto) {

        if (aideDistribueeId == null) {
            throw new RuntimeException(
                    "L'identifiant de la distribution est obligatoire");
        }

        if (dto == null) {
            throw new RuntimeException(
                    "Les données de la preuve sont obligatoires");
        }

        AideDistribuee aide = aideDistribueeRepository
                .findById(aideDistribueeId)
                .orElseThrow(() ->
                        new RuntimeException("Distribution introuvable"));

        verifierOrganisationConnectee(aide);

        PreuveDistribution preuve =
                PreuveDistributionMapper.toEntity(dto, aide);

        PreuveDistribution preuveEnregistree =
                preuveRepository.save(preuve);

        return PreuveDistributionMapper.toResponseDTO(
                preuveEnregistree);
    }

    /**
     * Téléverser un fichier justificatif.
     *
     * Vidéo : maximum 200 Mo.
     * Image et document : maximum 100 Mo.
     */
    @Override
    public PreuveDistributionResponseDTO televerser(
            Integer aideDistribueeId,
            MultipartFile fichier,
            TypeMedia typeMedia) {

        if (aideDistribueeId == null) {
            throw new RuntimeException(
                    "L'identifiant de la distribution est obligatoire");
        }

        AideDistribuee aide = aideDistribueeRepository
                .findById(aideDistribueeId)
                .orElseThrow(() ->
                        new RuntimeException("Distribution introuvable"));

        verifierOrganisationConnectee(aide);

        if (fichier == null || fichier.isEmpty()) {
            throw new RuntimeException(
                    "Veuillez sélectionner un fichier");
        }

        if (typeMedia == null) {
            throw new RuntimeException(
                    "Le type de média est obligatoire");
        }

        // 1. Vérifier la taille maximale selon le type de média.
        long tailleMaximale;

        if (typeMedia == TypeMedia.VIDEO) {
            tailleMaximale = TAILLE_MAX_VIDEO;
        } else {
            tailleMaximale = TAILLE_MAX_IMAGE_DOCUMENT;
        }

        if (fichier.getSize() > tailleMaximale) {
            if (typeMedia == TypeMedia.VIDEO) {
                throw new RuntimeException(
                        "La vidéo ne doit pas dépasser 200 Mo");
            } else {
                throw new RuntimeException(
                        "L'image ou le document ne doit pas dépasser 100 Mo");
            }
        }

        // 2. Vérifier le nom du fichier.
        String nomOriginal = fichier.getOriginalFilename();

        if (nomOriginal == null || nomOriginal.isBlank()) {
            throw new RuntimeException("Nom de fichier invalide");
        }

        // Éviter de conserver un chemin transmis par le client.
        String nomNettoye = Paths.get(nomOriginal)
                .getFileName()
                .toString();

        int position = nomNettoye.lastIndexOf('.');

        String extension = position >= 0
                ? nomNettoye.substring(position).toLowerCase(Locale.ROOT)
                : "";

        // 3. Vérifier les extensions autorisées.
        if (!extensionAutorisee(typeMedia, extension)) {
            throw new RuntimeException(
                    "Format de fichier non autorisé pour ce type de média");
        }

        // 4. Vérifier le type MIME déclaré par le client.
        String contentType = fichier.getContentType();

        if (contentType == null
                || !typeMimeValide(typeMedia, contentType)) {
            throw new RuntimeException(
                    "Le type du fichier ne correspond pas au type de média sélectionné");
        }

        // 5. Générer un nom de fichier unique.
        String nomUnique = UUID.randomUUID() + extension;

        Path dossier = Paths.get(dossierUpload)
                .toAbsolutePath()
                .normalize();

        Path destination = dossier.resolve(nomUnique).normalize();

        if (!destination.startsWith(dossier)) {
            throw new RuntimeException("Chemin de fichier invalide");
        }

        boolean fichierCopie = false;

        try {
            // 6. Créer le dossier si nécessaire.
            Files.createDirectories(dossier);

            // 7. Enregistrer le fichier sur le disque.
            try (var inputStream = fichier.getInputStream()) {
                Files.copy(inputStream, destination);
                fichierCopie = true;
            }

            // 8. Enregistrer les informations en base de données.
            PreuveDistribution preuve = new PreuveDistribution();

            preuve.setAideDistribuee(aide);
            preuve.setNomFichier(nomUnique);
            preuve.setUrlFichier(PREFIXE_URL + nomUnique);
            preuve.setTypeMedia(typeMedia);

            PreuveDistribution preuveEnregistree =
                    preuveRepository.save(preuve);

            return PreuveDistributionMapper.toResponseDTO(
                    preuveEnregistree);

        } catch (IOException | RuntimeException e) {

            // Nettoyer le fichier si l'enregistrement échoue.
            if (fichierCopie) {
                try {
                    Files.deleteIfExists(destination);
                } catch (IOException erreurSuppression) {
                    e.addSuppressed(erreurSuppression);
                }
            }

            throw new RuntimeException(
                    "Erreur lors de l'enregistrement de la preuve : "
                            + e.getMessage(),
                    e);
        }
    }

    /**
     * Vérifier les extensions acceptées.
     */
    private boolean extensionAutorisee(
            TypeMedia typeMedia,
            String extension) {

        return switch (typeMedia) {
            case IMAGE -> List.of(
                    ".jpg", ".jpeg", ".png", ".gif", ".webp"
            ).contains(extension);

            case VIDEO -> List.of(
                    ".mp4", ".mov", ".avi", ".mkv", ".webm"
            ).contains(extension);

            case DOCUMENT -> List.of(
                    ".pdf", ".txt", ".doc", ".docx"
            ).contains(extension);
        };
    }

    /**
     * Vérifier le type MIME.
     */
    private boolean typeMimeValide(
            TypeMedia typeMedia,
            String contentType) {

        String mime = contentType.toLowerCase(Locale.ROOT);

        return switch (typeMedia) {
            case IMAGE -> mime.startsWith("image/");
            case VIDEO -> mime.startsWith("video/");
            case DOCUMENT -> List.of(
                    "application/pdf",
                    "text/plain",
                    "application/msword",
                    "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            ).contains(mime);
        };
    }

    /**
     * Récupérer une preuve par son identifiant.
     */
    @Override
    @Transactional(readOnly = true)
    public PreuveDistributionResponseDTO getById(Integer id) {

        PreuveDistribution preuve = preuveRepository.findById(id)
                .orElseThrow(() ->
                        new RuntimeException("Preuve introuvable"));

        verifierDroitConsultation(preuve.getAideDistribuee());

        return PreuveDistributionMapper.toResponseDTO(preuve);
    }

    /**
     * Récupérer toutes les preuves d'une distribution.
     */
    @Override
    @Transactional(readOnly = true)
    public List<PreuveDistributionResponseDTO> getByDistribution(
            Integer aideDistribueeId) {

        if (aideDistribueeId == null) {
            throw new RuntimeException("Distribution introuvable");
        }

        AideDistribuee aide = aideDistribueeRepository
                .findById(aideDistribueeId)
                .orElseThrow(() ->
                        new RuntimeException("Distribution introuvable"));

        verifierDroitConsultation(aide);

        return preuveRepository
                .findByAideDistribueeId(aideDistribueeId)
                .stream()
                .map(PreuveDistributionMapper::toResponseDTO)
                .toList();
    }

    /**
     * Supprimer une preuve et son fichier physique.
     */
    @Override
    public void supprimer(Integer id) {

        PreuveDistribution preuve = preuveRepository.findById(id)
                .orElseThrow(() ->
                        new RuntimeException("Preuve introuvable"));

        verifierOrganisationConnectee(preuve.getAideDistribuee());

        String url = preuve.getUrlFichier();

        if (url != null && url.startsWith(PREFIXE_URL)) {

            String nomFichier = url.substring(PREFIXE_URL.length());

            Path dossier = Paths.get(dossierUpload)
                    .toAbsolutePath()
                    .normalize();

            Path fichier = dossier.resolve(nomFichier).normalize();

            if (fichier.startsWith(dossier)) {
                try {
                    Files.deleteIfExists(fichier);
                } catch (IOException e) {
                    throw new RuntimeException(
                            "Impossible de supprimer le fichier", e);
                }
            }
        }

        preuveRepository.delete(preuve);
    }
}
