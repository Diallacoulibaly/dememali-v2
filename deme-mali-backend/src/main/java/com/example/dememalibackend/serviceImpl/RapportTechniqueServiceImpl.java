package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.Enum.StatutEtudeTerrain;
import com.example.dememalibackend.dto.DetailRapportTechniqueRequestDTO;
import com.example.dememalibackend.dto.RapportTechniqueRequestDTO;
import com.example.dememalibackend.dto.RapportTechniqueResponseDTO;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.DetailRapportTechnique;
import com.example.dememalibackend.entity.RapportBesoin;
import com.example.dememalibackend.entity.RapportTechnique;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.exceptions.BadRequestException;
import com.example.dememalibackend.exceptions.ResourceNotFoundException;
import com.example.dememalibackend.mappers.RapportTechniqueMapper;
import com.example.dememalibackend.repository.RapportBesoinRepository;
import com.example.dememalibackend.repository.RapportTechniqueRepository;
import com.example.dememalibackend.service.RapportTechniqueService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Transactional
public class RapportTechniqueServiceImpl implements RapportTechniqueService {

    private final RapportTechniqueRepository rapportTechniqueRepository;
    private final RapportBesoinRepository rapportBesoinRepository;
    private final RapportTechniqueMapper rapportTechniqueMapper;
    private final CustomUserDetailsService customUserDetailsService;
    private final DemandeAideVisibilite demandeAideVisibilite;

    @Override
    public RapportTechniqueResponseDTO creer(
            RapportTechniqueRequestDTO dto) {

        if (dto == null || dto.getRapportBesoinId() == null) {
            throw new BadRequestException(
                    "Le rapport de besoin est obligatoire."
            );
        }

        RapportBesoin rapportBesoin =
                rapportBesoinRepository.findById(dto.getRapportBesoinId())
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        "Rapport de besoin introuvable."
                                ));

        // Vérifier que l'organisation connectée possède la demande.
        verifierOrganisationProprietaire(rapportBesoin);

        if (rapportBesoin.getEtudeTerrain() == null
                || rapportBesoin.getEtudeTerrain().getStatus()
                != StatutEtudeTerrain.TERMINEE) {

            throw new BadRequestException(
                    "L'étude de terrain doit être terminée."
            );
        }

        if (rapportTechniqueRepository
                .findByRapportBesoinId(rapportBesoin.getId())
                .isPresent()) {

            throw new BadRequestException(
                    "Ce rapport de besoin possède déjà un rapport technique."
            );
        }

        if (dto.getDetails() == null || dto.getDetails().isEmpty()) {
            throw new BadRequestException(
                    "Ajoute au moins un article au rapport technique."
            );
        }

        RapportTechnique rapport =
                rapportTechniqueMapper.toEntity(dto, rapportBesoin);

        rapport.setDateCreation(LocalDate.now());

        List<DetailRapportTechnique> details = new ArrayList<>();

        // Parcourir les articles reçus du formulaire.
        for (DetailRapportTechniqueRequestDTO detailDTO : dto.getDetails()) {

            if (detailDTO == null
                    || detailDTO.getDesignation() == null
                    || detailDTO.getDesignation().isBlank()) {

                throw new BadRequestException(
                        "La désignation de chaque article est obligatoire."
                );
            }

            if (detailDTO.getQuantite() == null
                    || detailDTO.getQuantite() <= 0) {

                throw new BadRequestException(
                        "La quantité doit être supérieure à zéro."
                );
            }

            if (detailDTO.getPrixUnitaire() == null
                    || detailDTO.getPrixUnitaire() < 0) {

                throw new BadRequestException(
                        "Le prix unitaire doit être positif ou nul."
                );
            }

            String designation = detailDTO.getDesignation().trim();

            String unite = detailDTO.getUnite() == null
                    ? ""
                    : detailDTO.getUnite().trim();

            DetailRapportTechnique articleExiste = null;

            // Chercher si cet article existe déjà dans la liste.
            for (DetailRapportTechnique article : details) {

                String designationExistante =
                        article.getDesignation().trim();

                String uniteExistante = article.getUnite() == null
                        ? ""
                        : article.getUnite().trim();

                if (designation.equalsIgnoreCase(designationExistante)
                        && unite.equalsIgnoreCase(uniteExistante)
                        && Objects.equals(
                        article.getPrixUnitaire(),
                        detailDTO.getPrixUnitaire())) {

                    articleExiste = article;
                    break;
                }
            }

            if (articleExiste != null) {

                // Article identique : additionner les quantités.
                int nouvelleQuantite =
                        articleExiste.getQuantite()
                                + detailDTO.getQuantite();

                articleExiste.setQuantite(nouvelleQuantite);

                articleExiste.setMontant(
                        nouvelleQuantite
                                * articleExiste.getPrixUnitaire()
                );

            } else {

                // Nouvel article : créer une ligne.
                DetailRapportTechnique detail =
                        new DetailRapportTechnique();

                detail.setDesignation(designation);
                detail.setQuantite(detailDTO.getQuantite());
                detail.setUnite(unite);
                detail.setPrixUnitaire(detailDTO.getPrixUnitaire());

                detail.setMontant(
                        detailDTO.getQuantite()
                                * detailDTO.getPrixUnitaire()
                );

                detail.setRapportTechnique(rapport);

                details.add(detail);
            }
        }

        // Calculer le budget total.
        double montantFinal = 0.0;

        for (DetailRapportTechnique detail : details) {
            montantFinal += detail.getMontant();
        }

        if (!Double.isFinite(montantFinal) || montantFinal <= 0) {
            throw new BadRequestException(
                    "Le montant final calculé est invalide."
            );
        }

        rapport.setDetails(details);
        rapport.setMontantFinal(montantFinal);

        RapportTechnique sauvegarde =
                rapportTechniqueRepository.save(rapport);

        return rapportTechniqueMapper.toDTO(sauvegarde);
    }

    @Override
    @Transactional(readOnly = true)
    public RapportTechniqueResponseDTO getById(Integer id) {

        RapportTechnique rapport = getEntity(id);

        verifierAccesRapport(rapport);

        return rapportTechniqueMapper.toDTO(rapport);
    }

    @Override
    @Transactional(readOnly = true)
    public List<RapportTechniqueResponseDTO> getAll() {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        return rapportTechniqueRepository.findAll()
                .stream()
                .filter(rapport ->
                        peutConsulterRapport(rapport, utilisateur))
                .map(rapportTechniqueMapper::toDTO)
                .toList();
    }

    @Override
    public RapportTechniqueResponseDTO modifier(
            Integer id,
            RapportTechniqueRequestDTO dto) {

        if (dto == null) {
            throw new BadRequestException(
                    "Les données de modification sont obligatoires."
            );
        }

        RapportTechnique rapport = getEntity(id);

        // Vérifier que l'organisation connectée possède la demande.
        verifierOrganisationProprietaire(rapport.getRapportBesoin());

        // Vérifier si la demande d'aide est déjà validée.
        RapportBesoin rapportBesoin = rapport.getRapportBesoin();

        if (rapportBesoin != null
                && rapportBesoin.getEtudeTerrain() != null
                && rapportBesoin.getEtudeTerrain().getDemandeAide() != null
                && rapportBesoin.getEtudeTerrain()
                .getDemandeAide().getStatut()
                == StatutDemande.VALIDEE) {

            throw new BadRequestException(
                    "Impossible de modifier le rapport technique : "
                            + "la demande d'aide est déjà validée."
            );
        }

        rapport.setDescriptionTechnique(
                dto.getDescriptionTechnique()
        );

        if (dto.getDetails() == null) {
            throw new BadRequestException(
                    "La liste des articles est obligatoire."
            );
        }

        List<DetailRapportTechnique> anciensDetails =
                rapport.getDetails();

        if (anciensDetails == null) {
            anciensDetails = new ArrayList<>();
            rapport.setDetails(anciensDetails);
        }

        // Garder les anciens articles dans une liste séparée.
        List<DetailRapportTechnique> detailsExistants =
                new ArrayList<>(anciensDetails);

        // Préparer la liste finale des articles.
        List<DetailRapportTechnique> nouveauxDetails =
                new ArrayList<>();

        for (DetailRapportTechniqueRequestDTO detailDTO : dto.getDetails()) {

            if (detailDTO == null
                    || detailDTO.getDesignation() == null
                    || detailDTO.getDesignation().isBlank()) {

                throw new BadRequestException(
                        "La désignation de chaque article est obligatoire."
                );
            }

            if (detailDTO.getQuantite() == null
                    || detailDTO.getQuantite() <= 0) {

                throw new BadRequestException(
                        "La quantité doit être supérieure à zéro."
                );
            }

            if (detailDTO.getPrixUnitaire() == null
                    || detailDTO.getPrixUnitaire() < 0) {

                throw new BadRequestException(
                        "Le prix unitaire doit être positif ou nul."
                );
            }

            DetailRapportTechnique detail = null;

            // Si l'ID existe, rechercher l'article correspondant.
            if (detailDTO.getId() != null) {

                for (DetailRapportTechnique ancien : detailsExistants) {

                    if (detailDTO.getId().equals(ancien.getId())) {
                        detail = ancien;
                        break;
                    }
                }

                if (detail == null) {
                    throw new BadRequestException(
                            "Article introuvable dans ce rapport technique."
                    );
                }

            } else {

                // Sans ID, il s'agit d'un nouvel article.
                detail = new DetailRapportTechnique();
                detail.setRapportTechnique(rapport);
            }

            detail.setDesignation(detailDTO.getDesignation().trim());
            detail.setQuantite(detailDTO.getQuantite());

            detail.setUnite(
                    detailDTO.getUnite() == null
                            ? ""
                            : detailDTO.getUnite().trim()
            );

            detail.setPrixUnitaire(detailDTO.getPrixUnitaire());

            detail.setMontant(
                    detailDTO.getQuantite()
                            * detailDTO.getPrixUnitaire()
            );

            nouveauxDetails.add(detail);
        }

        // Fusionner les articles identiques.
        List<DetailRapportTechnique> detailsFusionnes =
                new ArrayList<>();

        for (DetailRapportTechnique article : nouveauxDetails) {

            DetailRapportTechnique articleExiste = null;

            for (DetailRapportTechnique existant : detailsFusionnes) {

                boolean memeDesignation =
                        article.getDesignation().equalsIgnoreCase(
                                existant.getDesignation()
                        );

                boolean memeUnite = Objects.equals(
                        article.getUnite() == null
                                ? ""
                                : article.getUnite().trim(),
                        existant.getUnite() == null
                                ? ""
                                : existant.getUnite().trim()
                );

                boolean memePrix = Objects.equals(
                        article.getPrixUnitaire(),
                        existant.getPrixUnitaire()
                );

                if (memeDesignation && memeUnite && memePrix) {
                    articleExiste = existant;
                    break;
                }
            }

            if (articleExiste != null) {

                int quantiteTotale =
                        articleExiste.getQuantite()
                                + article.getQuantite();

                articleExiste.setQuantite(quantiteTotale);

                articleExiste.setMontant(
                        quantiteTotale
                                * articleExiste.getPrixUnitaire()
                );

            } else {
                detailsFusionnes.add(article);
            }
        }

        // Remplacer la collection par les articles conservés.
        anciensDetails.clear();

        for (DetailRapportTechnique detail : detailsFusionnes) {
            detail.setRapportTechnique(rapport);
            anciensDetails.add(detail);
        }

        // Recalculer le montant total.
        double montantFinal = 0.0;

        for (DetailRapportTechnique detail : anciensDetails) {
            montantFinal += detail.getMontant();
        }

        if (!Double.isFinite(montantFinal)) {
            throw new BadRequestException(
                    "Le montant total calculé est invalide."
            );
        }

        rapport.setMontantFinal(montantFinal);

        RapportTechnique sauvegarde =
                rapportTechniqueRepository.save(rapport);

        return rapportTechniqueMapper.toDTO(sauvegarde);
    }

    @Override
    public void supprimer(Integer id) {

        RapportTechnique rapport = getEntity(id);

        // Vérifier si la demande liée est validée.
        RapportBesoin rapportBesoin = rapport.getRapportBesoin();

        if (rapportBesoin != null
                && rapportBesoin.getEtudeTerrain() != null
                && rapportBesoin.getEtudeTerrain().getDemandeAide() != null
                && rapportBesoin.getEtudeTerrain()
                .getDemandeAide().getStatut()
                == StatutDemande.VALIDEE) {

            throw new BadRequestException(
                    "Impossible de supprimer le rapport technique : la demande d'aide est déjà validée."
            );



        }

        rapportTechniqueRepository.delete(rapport);
    }

    @Override
    @Transactional(readOnly = true)
    public RapportTechniqueResponseDTO getByRapportBesoin(
            Integer rapportBesoinId) {

        // Vérifier l'existence du rapport de besoin et les droits
        // avant de retourner le rapport technique associé.
        RapportBesoin rapportBesoin = rapportBesoinRepository
                .findById(rapportBesoinId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Rapport de besoin introuvable."
                        ));

        verifierAccesRapportBesoin(rapportBesoin);

        RapportTechnique rapport = rapportTechniqueRepository
                .findByRapportBesoinId(rapportBesoinId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Rapport technique introuvable pour le rapport de besoin : "
                                        + rapportBesoinId));

        return rapportTechniqueMapper.toDTO(rapport);
    }

    private RapportTechnique getEntity(Integer id) {

        return rapportTechniqueRepository.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Rapport technique introuvable."));
    }

    /**
     * Seule l'organisation propriétaire peut créer ou modifier
     * un rapport technique.
     */
    private void verifierOrganisationProprietaire(
            RapportBesoin rapportBesoin) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (!estRole(utilisateur, "ORGANISATIONPARTENAIRE")) {
            throw new AccessDeniedException(
                    "Seule une organisation partenaire peut effectuer cette opération.");
        }

        if (rapportBesoin == null
                || rapportBesoin.getEtudeTerrain() == null
                || rapportBesoin.getEtudeTerrain().getDemandeAide() == null
                || rapportBesoin.getEtudeTerrain()
                .getDemandeAide().getOrganisationPartenaire() == null
                || !Objects.equals(
                        rapportBesoin.getEtudeTerrain()
                                .getDemandeAide()
                                .getOrganisationPartenaire().getId(),
                        utilisateur.getId())) {

            throw new AccessDeniedException(
                    "Vous ne pouvez pas gérer le rapport technique de cette organisation.");
        }
    }

    /**
     * Vérifie les droits de consultation d'un rapport technique.
     */
    private void verifierAccesRapport(RapportTechnique rapport) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (!peutConsulterRapport(rapport, utilisateur)) {
            throw new AccessDeniedException(
                    "Vous n'êtes pas autorisé à consulter ce rapport technique.");
        }
    }

    /**
     * Vérifie les droits de consultation d'un rapport de besoin.
     */
    private void verifierAccesRapportBesoin(RapportBesoin rapportBesoin) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (!peutConsulterRapportBesoin(rapportBesoin, utilisateur)) {
            throw new AccessDeniedException(
                    "Vous n'êtes pas autorisé à consulter ce rapport de besoin.");
        }
    }

    private boolean peutConsulterRapport(
            RapportTechnique rapport,
            Utilisateur utilisateur) {

        if (rapport == null || rapport.getRapportBesoin() == null) {
            return false;
        }

        return peutConsulterRapportBesoin(
                rapport.getRapportBesoin(), utilisateur);
    }

    private boolean peutConsulterRapportBesoin(
            RapportBesoin rapportBesoin,
            Utilisateur utilisateur) {

        if (rapportBesoin == null
                || rapportBesoin.getEtudeTerrain() == null
                || rapportBesoin.getEtudeTerrain().getDemandeAide() == null
                || utilisateur == null) {
            return false;
        }

        DemandeAide demande =
                rapportBesoin.getEtudeTerrain().getDemandeAide();
        System.out.println("===== VERIFICATION RAPPORT TECHNIQUE =====");
        System.out.println("Utilisateur connecté ID : " + utilisateur.getId());
        System.out.println("Rôle connecté : " + utilisateur.getRole());
        System.out.println("Rapport besoin ID : " + rapportBesoin.getId());

        System.out.println("Organisation de la demande ID : "
                + (demande.getOrganisationPartenaire() != null
                ? demande.getOrganisationPartenaire().getId()
                : "NULL"));

        System.out.println("==========================================");

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
