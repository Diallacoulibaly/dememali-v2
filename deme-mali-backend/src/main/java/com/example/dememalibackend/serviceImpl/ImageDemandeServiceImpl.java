
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.dto.ImageDemandeResponseDTO;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.ImageDemande;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.mappers.ImageDemandeMapper;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.repository.ImageDemandeRepository;
import com.example.dememalibackend.service.ImageDemandeService;
import com.example.dememalibackend.service.FichierImageDemandeService;

import lombok.RequiredArgsConstructor;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class ImageDemandeServiceImpl implements ImageDemandeService {

    private final ImageDemandeRepository repository;
    private final DemandeAideRepository demandeRepository;
    private final ImageDemandeMapper mapper;
    private final FichierImageDemandeService fichierImageService;
    private final CustomUserDetailsService customUserDetailsService;
    private final DemandeAideVisibilite demandeAideVisibilite;

    /**
     * Ajouter une image à une demande d'aide.
     */
    @Override
    @Transactional
    public ImageDemandeResponseDTO creer(
            Integer demandeAideId,
            MultipartFile fichier) {

        if (fichier == null || fichier.isEmpty()) {
            throw new IllegalArgumentException(
                    "Veuillez sélectionner une image."
            );
        }

        DemandeAide demande = demandeRepository
                .findById(demandeAideId)
                .orElseThrow(() -> new RuntimeException(
                        "Demande d'aide introuvable."
                ));

        // Vérifier que l'organisation connectée possède cette demande
        verifierOrganisationProprietaire(demande);

        String nomUnique = fichierImageService.enregistrer(fichier);

        try {
            ImageDemande image = ImageDemande.builder()
                    .nomFichier(fichier.getOriginalFilename())
                    .cheminFichier(nomUnique)
                    .dateAjout(LocalDate.now())
                    .demandeAide(demande)
                    .build();

            ImageDemande imageEnregistree = repository.save(image);

            return mapper.toResponseDTO(imageEnregistree);

        } catch (RuntimeException e) {
            fichierImageService.supprimer(nomUnique);
            throw e;
        }
    }

    /**
     * Récupérer une image par son identifiant.
     */
    @Override
    @Transactional(readOnly = true)
    public ImageDemandeResponseDTO getById(Integer id) {

        ImageDemande image = getImage(id);

        verifierAccesDemande(image.getDemandeAide());

        return mapper.toResponseDTO(image);
    }

    /**
     * Récupérer toutes les images accessibles.
     */
    @Override
    @Transactional(readOnly = true)
    public List<ImageDemandeResponseDTO> getAll() {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        return repository.findAll()
                .stream()
                .filter(image -> peutConsulterDemande(
                        image.getDemandeAide(),
                        utilisateur
                ))
                .map(mapper::toResponseDTO)
                .toList();
    }

    /**
     * Récupérer les images associées à une demande.
     */
    @Override
    @Transactional(readOnly = true)
    public List<ImageDemandeResponseDTO> getByDemande(
            Integer demandeAideId) {

        DemandeAide demande = demandeRepository
                .findById(demandeAideId)
                .orElseThrow(() -> new RuntimeException(
                        "Demande d'aide introuvable."
                ));

        verifierAccesDemande(demande);

        return repository.findByDemandeAideId(demandeAideId)
                .stream()
                .map(mapper::toResponseDTO)
                .toList();
    }

    /**
     * Remplacer l'image existante.
     */
    @Override
    @Transactional
    public ImageDemandeResponseDTO modifierImage(
            Integer id,
            MultipartFile fichier) {

        if (fichier == null || fichier.isEmpty()) {
            throw new IllegalArgumentException(
                    "Veuillez sélectionner une nouvelle image."
            );
        }

        ImageDemande image = getImage(id);

        // ADMIN ou organisation propriétaire
        verifierDroitModification(image.getDemandeAide());

        String ancienNom = image.getCheminFichier();

        String nouveauNom = fichierImageService.enregistrer(fichier);

        ImageDemande imageModifiee;

        try {
            image.setNomFichier(fichier.getOriginalFilename());
            image.setCheminFichier(nouveauNom);
            image.setDateAjout(LocalDate.now());

            imageModifiee = repository.save(image);

        } catch (RuntimeException e) {
            fichierImageService.supprimer(nouveauNom);
            throw e;
        }

        if (ancienNom != null && !ancienNom.isBlank()) {
            fichierImageService.supprimer(ancienNom);
        }

        return mapper.toResponseDTO(imageModifiee);
    }

    /**
     * Supprimer l'image et son fichier physique.
     */
    @Override
    @Transactional
    public void supprimer(Integer id) {

        ImageDemande image = getImage(id);

        // ADMIN ou organisation propriétaire
        verifierDroitModification(image.getDemandeAide());

        String nomFichier = image.getCheminFichier();

        if (nomFichier != null && !nomFichier.isBlank()) {
            fichierImageService.supprimer(nomFichier);
        }

        repository.delete(image);
    }

    // =====================================================
    // METHODES DE VERIFICATION DES ACCES
    // =====================================================

    /**
     * Vérifier que l'organisation connectée est propriétaire
     * de la demande.
     */
    private void verifierOrganisationProprietaire(
            DemandeAide demande) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (!"ORGANISATIONPARTENAIRE".equals(
                utilisateur.getRole().name())) {

            throw new AccessDeniedException(
                    "Seule une organisation partenaire peut ajouter une image."
            );
        }

        if (demande.getOrganisationPartenaire() == null
                || !Objects.equals(
                        demande.getOrganisationPartenaire().getId(),
                        utilisateur.getId())) {

            throw new AccessDeniedException(
                    "Vous ne pouvez pas ajouter une image à cette demande."
            );
        }
    }

    /**
     * Vérifier les droits de consultation d'une demande.
     */
    private void verifierAccesDemande(DemandeAide demande) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (!peutConsulterDemande(demande, utilisateur)) {
            throw new AccessDeniedException(
                    "Vous n'avez pas accès à cette image."
            );
        }
    }

    /**
     * Déterminer si l'utilisateur peut consulter une demande.
     */
    private boolean peutConsulterDemande(
            DemandeAide demande,
            Utilisateur utilisateur) {

        String role = utilisateur.getRole().name();

        // Administrateur : accès à toutes les demandes
        if ("ADMIN".equals(role)) {
            return true;
        }

        // Organisation : uniquement ses propres demandes
        if ("ORGANISATIONPARTENAIRE".equals(role)) {
            return demande.getOrganisationPartenaire() != null
                    && Objects.equals(
                            demande.getOrganisationPartenaire().getId(),
                            utilisateur.getId()
                    );
        }

        // Bénéficiaire : ses demandes ou une demande validée avec étude terminée
        if ("BENEFICIARE".equals(role)) {
            return (demande.getBeneficiaire() != null
                    && Objects.equals(
                            demande.getBeneficiaire().getId(),
                            utilisateur.getId()
                    ))
                    || demandeAideVisibilite.estValideeAvecEtudeTerminee(demande);
        }

        // Donateur : demandes ouvertes aux dons ou demandes auxquelles il a contribué
        if ("DONATEUR".equals(role)) {
            return demandeAideVisibilite.estOuverteAuxDons(demande)
                    || (demande.getDons() != null
                    && demande.getDons().stream()
                    .anyMatch(don ->
                            don.getDonateur() != null
                                    && Objects.equals(
                                            don.getDonateur().getId(),
                                            utilisateur.getId()
                                    )
                    ));
        }

        return false;
    }

    /**
     * Vérifier les droits de modification et de suppression.
     */
    private void verifierDroitModification(
            DemandeAide demande) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        String role = utilisateur.getRole().name();

        // Administrateur : accès à toutes les images
        if ("ADMIN".equals(role)) {
            return;
        }

        // Organisation : uniquement ses propres demandes
        if ("ORGANISATIONPARTENAIRE".equals(role)
                && demande.getOrganisationPartenaire() != null
                && Objects.equals(
                        demande.getOrganisationPartenaire().getId(),
                        utilisateur.getId())) {
            return;
        }

        throw new AccessDeniedException(
                "Vous n'avez pas le droit de modifier ou supprimer cette image."
        );
    }

    /**
     * Récupérer une image ou déclencher une erreur.
     */
    private ImageDemande getImage(Integer id) {

        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException(
                        "Image de la demande introuvable."
                ));
    }
}
