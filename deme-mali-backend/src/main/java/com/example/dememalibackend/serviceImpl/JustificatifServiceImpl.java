
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.dto.JustificatifRequestDTO;
import com.example.dememalibackend.dto.JustificatifResponseDTO;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.Justificatif;
import com.example.dememalibackend.entity.TypeJustificatif;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.mappers.JustificatifMapper;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.repository.JustificatifRepository;
import com.example.dememalibackend.repository.TypeJustificatifRepository;
import com.example.dememalibackend.service.FichierService;
import com.example.dememalibackend.service.JustificatifService;

import lombok.RequiredArgsConstructor;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class JustificatifServiceImpl
        implements JustificatifService {

    private final JustificatifRepository repository;
    private final TypeJustificatifRepository typeRepository;
    private final DemandeAideRepository demandeRepository;
    private final JustificatifMapper mapper;
    private final FichierService fichierService;
    private final CustomUserDetailsService customUserDetailsService;
    private final DemandeAideVisibilite demandeAideVisibilite;

    /**
     * Vérifier si la demande appartient à l'organisation
     * ou au bénéficiaire connecté.
     */
    private boolean estProprietaireDemande(
            DemandeAide demande,
            Utilisateur utilisateur) {

        if (utilisateur.getRole() == RoleEnum.ORGANISATIONPARTENAIRE) {

            return demande.getOrganisationPartenaire() != null
                    && Objects.equals(
                            demande.getOrganisationPartenaire().getId(),
                            utilisateur.getId()
                    );
        }

        if (utilisateur.getRole() == RoleEnum.BENEFICIARE) {

            return demande.getBeneficiaire() != null
                    && Objects.equals(
                            demande.getBeneficiaire().getId(),
                            utilisateur.getId()
                    );
        }

        return false;
    }

    /**
     * Vérifier les droits de gestion d'une demande.
     * Seuls l'organisation propriétaire et le bénéficiaire
     * concerné peuvent gérer ses justificatifs.
     */
    private void verifierDroitGestion(DemandeAide demande) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur.getRole() != RoleEnum.ORGANISATIONPARTENAIRE
                && utilisateur.getRole() != RoleEnum.BENEFICIARE) {

            throw new AccessDeniedException(
                    "Vous n'avez pas le droit de gérer ce justificatif."
            );
        }

        if (!estProprietaireDemande(demande, utilisateur)) {
            throw new AccessDeniedException(
                    "Vous ne pouvez pas gérer les justificatifs de cette demande."
            );
        }
    }

    /**
     * Vérifier si le donateur a contribué à une demande.
     */
    private boolean donateurAContribue(
            DemandeAide demande,
            Integer donateurId) {

        if (demande.getDons() == null) {
            return false;
        }

        return demande.getDons().stream()
                .anyMatch(don ->
                        don.getDonateur() != null
                                && Objects.equals(
                                        don.getDonateur().getId(),
                                        donateurId
                                )
                );
    }

    /**
     * Vérifier les droits de consultation d'une demande.
     */
    private void verifierDroitConsultation(DemandeAide demande) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        RoleEnum role = utilisateur.getRole();

        // ADMIN : consultation de toutes les demandes.
        if (role == RoleEnum.ADMIN) {
            return;
        }

        // Organisation : ses demandes. Bénéficiaire : ses demandes et les demandes publiées.
        if (role == RoleEnum.ORGANISATIONPARTENAIRE
                || role == RoleEnum.BENEFICIARE) {

            if (!estProprietaireDemande(demande, utilisateur)
                    && !(role == RoleEnum.BENEFICIARE
                    && demandeAideVisibilite.estValideeAvecEtudeTerminee(demande))) {
                throw new AccessDeniedException(
                        "Vous ne pouvez pas consulter les justificatifs de cette demande."
                );
            }

            return;
        }

        // DONATEUR : consultation uniquement des demandes auxquelles il a contribué.
        if (role == RoleEnum.DONATEUR) {

            if (!donateurAContribue(demande, utilisateur.getId())) {
                throw new AccessDeniedException(
                        "Vous n'avez pas contribué à cette demande."
                );
            }

            return;
        }

        throw new AccessDeniedException(
                "Vous n'avez pas le droit de consulter ces justificatifs."
        );
    }

    @Override
    public List<JustificatifResponseDTO> creer(
            JustificatifRequestDTO dto,
            List<MultipartFile> fichiers) {

        TypeJustificatif type = typeRepository
                .findById(dto.getTypeJustificatifId())
                .orElseThrow(() -> new RuntimeException(
                        "Type de justificatif introuvable"));

        DemandeAide demande = demandeRepository
                .findById(dto.getDemandeAideId())
                .orElseThrow(() -> new RuntimeException(
                        "Demande d'aide introuvable"));

        verifierDroitGestion(demande);

        List<JustificatifResponseDTO> resultats =
                new ArrayList<>();

        for (MultipartFile fichier : fichiers) {

            String nomFichierUnique =
                    fichierService.enregistrerFichier(fichier);

            dto.setNomFichier(
                    fichier.getOriginalFilename());

            dto.setCheminFichier(
                    nomFichierUnique);

            Justificatif justificatif = mapper.toEntity(
                    dto,
                    type,
                    demande);

            Justificatif saved =
                    repository.save(justificatif);

            resultats.add(
                    mapper.toResponseDTO(saved));
        }

        return resultats;
    }

    @Override
    public JustificatifResponseDTO getById(Integer id) {

        Justificatif justificatif = repository.findById(id)
                .orElseThrow(() -> new RuntimeException(
                        "Justificatif introuvable"));

        verifierDroitConsultation(justificatif.getDemandeAide());

        return mapper.toResponseDTO(justificatif);
    }

    @Override
    public List<JustificatifResponseDTO> getAll() {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        RoleEnum role = utilisateur.getRole();

        // ADMIN : tous les justificatifs.
        if (role == RoleEnum.ADMIN) {

            return repository.findAll()
                    .stream()
                    .map(mapper::toResponseDTO)
                    .toList();
        }

        // DONATEUR : pas d'accès à la liste globale.
        if (role == RoleEnum.DONATEUR) {
            throw new AccessDeniedException(
                    "Vous ne pouvez consulter que les justificatifs des demandes auxquelles vous avez contribué."
            );
        }

        // Organisation : ses demandes. Bénéficiaire : ses demandes et les demandes publiées.
        if (role == RoleEnum.ORGANISATIONPARTENAIRE
                || role == RoleEnum.BENEFICIARE) {

            return repository.findAll()
                    .stream()
                    .filter(justificatif ->
                            estProprietaireDemande(
                                    justificatif.getDemandeAide(),
                                    utilisateur
                            ) || (role == RoleEnum.BENEFICIARE
                                    && demandeAideVisibilite.estValideeAvecEtudeTerminee(
                                            justificatif.getDemandeAide()))
                    )
                    .map(mapper::toResponseDTO)
                    .toList();
        }

        throw new AccessDeniedException(
                "Vous n'avez pas le droit de consulter ces justificatifs."
        );
    }

    @Override
    public List<JustificatifResponseDTO> getByDemande(
            Integer demandeAideId) {

        DemandeAide demande = demandeRepository
                .findById(demandeAideId)
                .orElseThrow(() -> new RuntimeException(
                        "Demande d'aide introuvable"));

        verifierDroitConsultation(demande);

        return repository.findByDemandeAideId(demandeAideId)
                .stream()
                .map(mapper::toResponseDTO)
                .toList();
    }

    @Override
    public JustificatifResponseDTO modifier(
            Integer id,
            JustificatifRequestDTO dto) {

        Justificatif justificatif = repository.findById(id)
                .orElseThrow(() -> new RuntimeException(
                        "Justificatif introuvable"));

        verifierDroitGestion(justificatif.getDemandeAide());

        TypeJustificatif type = typeRepository
                .findById(dto.getTypeJustificatifId())
                .orElseThrow(() -> new RuntimeException(
                        "Type de justificatif introuvable"));

        justificatif.setNomFichier(dto.getNomFichier());
        justificatif.setCheminFichier(dto.getCheminFichier());
        justificatif.setTypeJustificatif(type);

        Justificatif updated = repository.save(justificatif);

        return mapper.toResponseDTO(updated);
    }

    @Override
    public void supprimer(Integer id) {

        Justificatif justificatif = repository.findById(id)
                .orElseThrow(() -> new RuntimeException(
                        "Justificatif introuvable"));

        verifierDroitGestion(justificatif.getDemandeAide());

        repository.deleteById(id);
    }
}
