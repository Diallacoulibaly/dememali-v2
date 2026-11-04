package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.Enum.StatutEtudeTerrain;
import com.example.dememalibackend.dto.RapportBesoinRequestDTO;
import com.example.dememalibackend.dto.RapportBesoinResponseDTO;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.EtudeTerrain;
import com.example.dememalibackend.entity.RapportBesoin;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.exceptions.BadRequestException;
import com.example.dememalibackend.exceptions.ResourceNotFoundException;
import com.example.dememalibackend.mappers.RapportBesoinMapper;
import com.example.dememalibackend.repository.EtudeTerrainRepository;
import com.example.dememalibackend.repository.RapportBesoinRepository;
import com.example.dememalibackend.service.RapportBesoinService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Transactional
public class RapportBesoinServiceImpl implements RapportBesoinService {

    private final RapportBesoinRepository rapportBesoinRepository;
    private final EtudeTerrainRepository etudeTerrainRepository;
    private final RapportBesoinMapper rapportBesoinMapper;
    private final CustomUserDetailsService customUserDetailsService;
    private final DemandeAideVisibilite demandeAideVisibilite;

    @Override
    public RapportBesoinResponseDTO creer(RapportBesoinRequestDTO dto) {

        if (dto == null || dto.getEtudeTerrainId() == null) {
            throw new BadRequestException(
                    "L'étude de terrain est obligatoire.");
        }

        EtudeTerrain etude = etudeTerrainRepository
                .findById(dto.getEtudeTerrainId())
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Étude de terrain introuvable."));

        // Vérifier que l'organisation connectée possède cette étude.
        verifierOrganisationProprietaire(etude);

        if (etude.getStatus() != StatutEtudeTerrain.TERMINEE) {
            throw new BadRequestException(
                    "L'étude doit être terminée avant de créer le rapport de besoin.");
        }

        if (rapportBesoinRepository
                .findByEtudeTerrainId(etude.getId())
                .isPresent()) {
            throw new BadRequestException(
                    "Cette étude possède déjà un rapport de besoin.");
        }

        if (dto.getTitre() == null || dto.getTitre().isBlank()
                || dto.getBesoinIdentifie() == null
                || dto.getBesoinIdentifie().isBlank()
                || dto.getSolutionProposee() == null
                || dto.getSolutionProposee().isBlank()) {
            throw new BadRequestException(
                    "Le titre, le besoin identifié et la solution proposée sont obligatoires.");
        }

        if (dto.getMontantEstime() == null
                || dto.getMontantEstime() <= 0) {
            throw new BadRequestException(
                    "Le montant estimé doit être supérieur à zéro.");
        }

        RapportBesoin rapport =
                rapportBesoinMapper.toEntity(dto, etude);

        rapport.setDateCreation(LocalDate.now());

        return rapportBesoinMapper.toDTO(
                rapportBesoinRepository.save(rapport));
    }

    @Override
    @Transactional(readOnly = true)
    public RapportBesoinResponseDTO getById(Integer id) {

        RapportBesoin rapportBesoin = getEntity(id);

        verifierAccesRapport(rapportBesoin);

        return rapportBesoinMapper.toDTO(rapportBesoin);
    }

    @Override
    @Transactional(readOnly = true)
    public List<RapportBesoinResponseDTO> getAll() {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        return rapportBesoinRepository
                .findAll()
                .stream()
                .filter(rapport ->
                        peutConsulterRapport(rapport, utilisateur))
                .map(rapportBesoinMapper::toDTO)
                .toList();
    }

    @Override
    public RapportBesoinResponseDTO modifier(
            Integer id,
            RapportBesoinRequestDTO dto) {

        RapportBesoin rapportBesoin = getEntity(id);

        // Vérifier que l'organisation connectée possède cette étude.
        verifierOrganisationProprietaire(
                rapportBesoin.getEtudeTerrain());

        // Récupérer la demande liée au rapport.
        EtudeTerrain etude = rapportBesoin.getEtudeTerrain();

        if (etude != null && etude.getDemandeAide() != null
                && etude.getDemandeAide().getStatut()
                == StatutDemande.VALIDEE) {

            throw new BadRequestException(
                    "Impossible de modifier le rapport de besoin : la demande d'aide est déjà validée."
            );
        }

        // Modifier les informations si la demande n'est pas validée.
        rapportBesoin.setTitre(dto.getTitre());
        rapportBesoin.setBesoinIdentifie(dto.getBesoinIdentifie());
        rapportBesoin.setDescriptionSituation(dto.getDescriptionSituation());
        rapportBesoin.setSolutionProposee(dto.getSolutionProposee());
        rapportBesoin.setMontantEstime(dto.getMontantEstime());

        RapportBesoin updated =
                rapportBesoinRepository.save(rapportBesoin);

        return rapportBesoinMapper.toDTO(updated);
    }

    @Override
    public void supprimer(Integer id) {

        RapportBesoin rapportBesoin = getEntity(id);

        // Vérifier si la demande liée est validée.
        EtudeTerrain etude = rapportBesoin.getEtudeTerrain();

        if (etude != null
                && etude.getDemandeAide() != null
                && etude.getDemandeAide().getStatut()
                == StatutDemande.VALIDEE) {

            throw new BadRequestException(
                    "Impossible de supprimer le rapport de besoin : la demande d'aide est déjà validée."
            );
        }

        rapportBesoinRepository.delete(rapportBesoin);
    }

    @Override
    @Transactional(readOnly = true)
    public RapportBesoinResponseDTO getByEtudeTerrain(
            Integer etudeTerrainId) {

        // Vérifier l'accès à l'étude avant de consulter son rapport.
        EtudeTerrain etude = etudeTerrainRepository
                .findById(etudeTerrainId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Étude de terrain introuvable."));

        verifierAccesEtude(etude);

        RapportBesoin rapportBesoin = rapportBesoinRepository
                .findByEtudeTerrainId(etudeTerrainId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Aucun rapport de besoin trouvé pour l'étude de terrain : "
                                + etudeTerrainId
                ));

        return rapportBesoinMapper.toDTO(rapportBesoin);
    }

    private RapportBesoin getEntity(Integer id) {

        return rapportBesoinRepository
                .findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Rapport de besoin introuvable"
                        )
                );
    }

    /**
     * Vérifie que seule l'organisation propriétaire
     * peut créer ou modifier un rapport.
     */
    private void verifierOrganisationProprietaire(EtudeTerrain etude) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (!estRole(utilisateur, "ORGANISATIONPARTENAIRE")) {
            throw new AccessDeniedException(
                    "Seule une organisation partenaire peut effectuer cette opération.");
        }

        if (etude == null
                || etude.getDemandeAide() == null
                || etude.getDemandeAide().getOrganisationPartenaire() == null
                || !Objects.equals(
                        etude.getDemandeAide()
                                .getOrganisationPartenaire().getId(),
                        utilisateur.getId())) {

            throw new AccessDeniedException(
                    "Vous ne pouvez pas gérer le rapport de cette organisation.");
        }
    }

    /**
     * Vérifie les droits de consultation d'une étude.
     */
    private void verifierAccesEtude(EtudeTerrain etude) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (!peutConsulterEtude(etude, utilisateur)) {
            throw new AccessDeniedException(
                    "Vous n'êtes pas autorisé à consulter cette étude de terrain.");
        }
    }

    /**
     * Vérifie les droits de consultation d'un rapport.
     */
    private void verifierAccesRapport(RapportBesoin rapport) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (!peutConsulterRapport(rapport, utilisateur)) {
            throw new AccessDeniedException(
                    "Vous n'êtes pas autorisé à consulter ce rapport de besoin.");
        }
    }

    private boolean peutConsulterEtude(
            EtudeTerrain etude,
            Utilisateur utilisateur) {

        if (etude == null || etude.getDemandeAide() == null) {
            return false;
        }

        return peutConsulterDemande(
                etude.getDemandeAide(), utilisateur);
    }

    private boolean peutConsulterRapport(
            RapportBesoin rapport,
            Utilisateur utilisateur) {

        if (rapport == null || rapport.getEtudeTerrain() == null) {
            return false;
        }

        return peutConsulterEtude(
                rapport.getEtudeTerrain(), utilisateur);
    }

    /**
     * Vérifie l'accès à une demande selon le rôle connecté.
     */
    private boolean peutConsulterDemande(
            DemandeAide demande,
            Utilisateur utilisateur) {

        if (demande == null || utilisateur == null) {
            return false;
        }

        if (estRole(utilisateur, "ADMIN")) {
            return true;
        }

        if (estRole(utilisateur, "ORGANISATIONPARTENAIRE")) {
            return demande.getOrganisationPartenaire() != null
                    && Objects.equals(
                            demande.getOrganisationPartenaire().getId(),
                            utilisateur.getId());
        }

        if (estRole(utilisateur, "BENEFICIARE")) {
            return (demande.getBeneficiaire() != null
                    && Objects.equals(
                            demande.getBeneficiaire().getId(),
                            utilisateur.getId()))
                    || demandeAideVisibilite.estValideeAvecEtudeTerminee(demande);
        }

        if (estRole(utilisateur, "DONATEUR")) {
            return demandeAideVisibilite.estOuverteAuxDons(demande)
                    || (demande.getDons() != null
                    && demande.getDons().stream()
                    .filter(Objects::nonNull)
                    .anyMatch(don ->
                            don.getDonateur() != null
                                    && Objects.equals(
                                            don.getDonateur().getId(),
                                            utilisateur.getId())));
        }

        return false;
    }

    private boolean estRole(Utilisateur utilisateur, String role) {

        return utilisateur != null
                && utilisateur.getRole() != null
                && role.equals(utilisateur.getRole().name());
    }
}
