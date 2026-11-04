package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.Enum.StatutPaiement;
import com.example.dememalibackend.Enum.StatutReception;
import com.example.dememalibackend.Enum.StatutValidation;

import com.example.dememalibackend.dto.AttributionDonLibreRequestDTO;
import com.example.dememalibackend.dto.AttributionDonLibreResponseDTO;
import com.example.dememalibackend.dto.OrganisationPrioritaireResponseDTO;

import com.example.dememalibackend.entity.Admin;
import com.example.dememalibackend.entity.AttributionDonLibre;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.DonFinancier;
import com.example.dememalibackend.entity.DonMateriel;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import com.example.dememalibackend.entity.Utilisateur;

import com.example.dememalibackend.mappers.AttributionDonLibreMapper;

import com.example.dememalibackend.repository.AdminRepository;
import com.example.dememalibackend.repository.AttributionDonLibreRepository;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.repository.DonFinancierRepository;
import com.example.dememalibackend.repository.DonMaterielRepository;
import com.example.dememalibackend.repository.OrganisationPartenaireRepository;
import com.example.dememalibackend.repository.PaiementDonRepository;

import com.example.dememalibackend.service.AttributionDonLibreService;

import jakarta.persistence.EntityNotFoundException;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class AttributionDonLibreServiceImpl
        implements AttributionDonLibreService {

    private final AttributionDonLibreRepository attributionRepository;
    private final DonFinancierRepository donFinancierRepository;
    private final DonMaterielRepository donMaterielRepository;
    private final OrganisationPartenaireRepository organisationRepository;
    private final AdminRepository adminRepository;
    private final DemandeAideRepository demandeRepository;
    private final PaiementDonRepository paiementRepository;
    private final AttributionDonLibreMapper mapper;
    private final CustomUserDetailsService customUserDetailsService;

    public AttributionDonLibreServiceImpl(
            AttributionDonLibreRepository attributionRepository,
            DonFinancierRepository donFinancierRepository,
            DonMaterielRepository donMaterielRepository,
            OrganisationPartenaireRepository organisationRepository,
            AdminRepository adminRepository,
            DemandeAideRepository demandeRepository,
            PaiementDonRepository paiementRepository,
            AttributionDonLibreMapper mapper,
            CustomUserDetailsService customUserDetailsService) {

        this.attributionRepository = attributionRepository;
        this.donFinancierRepository = donFinancierRepository;
        this.donMaterielRepository = donMaterielRepository;
        this.organisationRepository = organisationRepository;
        this.adminRepository = adminRepository;
        this.demandeRepository = demandeRepository;
        this.paiementRepository = paiementRepository;
        this.mapper = mapper;
        this.customUserDetailsService = customUserDetailsService;
    }

    // Attribuer un don libre : ADMIN uniquement
    @Override
    @Transactional
    public AttributionDonLibreResponseDTO attribuer(
            AttributionDonLibreRequestDTO dto,
            Integer administrateurId) {

        if (dto == null) {
            throw new IllegalArgumentException(
                    "Les informations sont obligatoires.");
        }

        Admin adminConnecte = verifierAdminConnecte();

        if (!adminConnecte.getId().equals(administrateurId)) {
            throw new AccessDeniedException(
                    "Vous ne pouvez pas effectuer une attribution au nom d'un autre administrateur.");
        }

        Admin admin = adminRepository.findById(administrateurId)
                .orElseThrow(() -> new EntityNotFoundException(
                        "Administrateur introuvable."));

        boolean donFinancier = dto.getDonFinancierId() != null;
        boolean donMateriel = dto.getDonMaterielId() != null;

        if (donFinancier == donMateriel) {
            throw new IllegalArgumentException(
                    "Choisissez un seul don : financier ou matériel.");
        }

        if (donFinancier) {
            return attribuerDonFinancier(dto, admin);
        }

        return attribuerDonMateriel(dto, admin);
    }

    // Attribution d'un don financier
    private AttributionDonLibreResponseDTO attribuerDonFinancier(
            AttributionDonLibreRequestDTO dto,
            Admin admin) {

        DonFinancier don = donFinancierRepository
                .findByIdForUpdate(dto.getDonFinancierId())
                .orElseThrow(() -> new EntityNotFoundException(
                        "Don financier introuvable."));

        if (don.getDemandeAide() != null) {
            throw new IllegalArgumentException(
                    "Ce don n'est pas un don libre.");
        }

        if (don.getMontant() == null || don.getMontant() <= 0) {
            throw new IllegalArgumentException(
                    "Le montant du don est invalide.");
        }

        boolean paiementConfirme =
                paiementRepository.existsByDonFinancier_IdAndStatut(
                        don.getId(), StatutPaiement.CONFIRME);

        if (!paiementConfirme) {
            throw new IllegalArgumentException(
                    "Le paiement n'est pas confirmé.");
        }

        if (dto.getMontantAttribue() == null
                || dto.getMontantAttribue() <= 0) {
            throw new IllegalArgumentException(
                    "Le montant attribué doit être positif.");
        }

        if (dto.getQuantiteAttribuee() != null) {
            throw new IllegalArgumentException(
                    "Un don financier ne possède pas de quantité.");
        }

        // Cette vérification reste obligatoire pour une attribution.
        Double montantAttribue =
                attributionRepository.calculerMontantAttribue(don.getId());

        if (montantAttribue == null) {
            montantAttribue = 0.0;
        }

        double montantDisponible = don.getMontant() - montantAttribue;

        if (dto.getMontantAttribue() > montantDisponible) {
            throw new IllegalArgumentException(
                    "Le montant demandé dépasse le montant disponible.");
        }

        OrganisationPartenaire organisation =
                trouverOrganisationPrioritaire(true, null);

        verifierOrganisation(
                dto.getOrganisationPartenaireId(), organisation);

        double score = calculerScore(organisation, true, null);

        AttributionDonLibre attribution = new AttributionDonLibre();

        attribution.setDateAttribution(LocalDate.now());
        attribution.setMontantAttribue(dto.getMontantAttribue());
        attribution.setQuantiteAttribuee(null);
        attribution.setScorePriorite(score);
        attribution.setDonFinancier(don);
        attribution.setDonMateriel(null);
        attribution.setOrganisationPartenaire(organisation);
        attribution.setAdministrateur(admin);

        AttributionDonLibre resultat =
                attributionRepository.save(attribution);

        return mapper.toDTO(resultat);
    }

    // Attribution d'un don matériel
    private AttributionDonLibreResponseDTO attribuerDonMateriel(
            AttributionDonLibreRequestDTO dto,
            Admin admin) {

        DonMateriel don = donMaterielRepository
                .findByIdForUpdate(dto.getDonMaterielId())
                .orElseThrow(() -> new EntityNotFoundException(
                        "Don matériel introuvable."));

        if (don.getDemandeAide() != null) {
            throw new IllegalArgumentException(
                    "Ce don n'est pas un don libre.");
        }

        if (don.getStatutReception() != StatutReception.RECU) {
            throw new IllegalArgumentException(
                    "Le don matériel doit être réceptionné.");
        }

        if (don.getQuantiteRecue() == null
                || don.getQuantiteRecue() <= 0) {
            throw new IllegalArgumentException(
                    "La quantité reçue est invalide.");
        }

        if (dto.getQuantiteAttribuee() == null
                || dto.getQuantiteAttribuee() <= 0) {
            throw new IllegalArgumentException(
                    "La quantité attribuée doit être positive.");
        }

        if (dto.getMontantAttribue() != null) {
            throw new IllegalArgumentException(
                    "Un don matériel ne possède pas de montant attribué.");
        }

        // Cette vérification reste obligatoire pour une attribution.
        Integer quantiteAttribuee =
                attributionRepository.calculerQuantiteAttribuee(don.getId());

        if (quantiteAttribuee == null) {
            quantiteAttribuee = 0;
        }

        int quantiteDisponible =
                don.getQuantiteRecue() - quantiteAttribuee;

        if (dto.getQuantiteAttribuee() > quantiteDisponible) {
            throw new IllegalArgumentException(
                    "La quantité demandée dépasse le stock disponible.");
        }

        OrganisationPartenaire organisation =
                trouverOrganisationPrioritaire(false, don);

        verifierOrganisation(
                dto.getOrganisationPartenaireId(), organisation);

        double score = calculerScore(organisation, false, don);

        AttributionDonLibre attribution = new AttributionDonLibre();

        attribution.setDateAttribution(LocalDate.now());
        attribution.setMontantAttribue(null);
        attribution.setQuantiteAttribuee(dto.getQuantiteAttribuee());
        attribution.setScorePriorite(score);
        attribution.setDonFinancier(null);
        attribution.setDonMateriel(don);
        attribution.setOrganisationPartenaire(organisation);
        attribution.setAdministrateur(admin);

        AttributionDonLibre resultat =
                attributionRepository.save(attribution);

        return mapper.toDTO(resultat);
    }

    // Rechercher l'organisation ayant le meilleur score
    private OrganisationPartenaire trouverOrganisationPrioritaire(
            boolean financier,
            DonMateriel donMateriel) {

        List<OrganisationPartenaire> organisations =
                organisationRepository.findByStatutValidation(
                        StatutValidation.VALIDEE);

        OrganisationPartenaire meilleureOrganisation = null;
        double meilleurScore = -1;

        for (OrganisationPartenaire organisation : organisations) {

            boolean demandeTrouvee = false;

            List<DemandeAide> demandes =
                    demandeRepository.findByOrganisationPartenaireId(
                            organisation.getId());

            for (DemandeAide demande : demandes) {

                if (demande.getStatut() != StatutDemande.VALIDEE) {
                    continue;
                }

                if (demande.getTypeDemandeAide() == null) {
                    continue;
                }

                String type = demande.getTypeDemandeAide().name();

                if (financier && !type.equals("FINANCIERE")) {
                    continue;
                }

                if (!financier && !type.equals("MATERIELLE")) {
                    continue;
                }

                if (financier) {
                    double necessaire =
                            demande.getMontantNecessaire() == null
                                    ? 0 : demande.getMontantNecessaire();

                    double collecte =
                            demande.getMontantCollecte() == null
                                    ? 0 : demande.getMontantCollecte();

                    if (necessaire <= collecte) {
                        continue;
                    }
                } else if (!correspondAuBesoin(demande, donMateriel)) {
                    continue;
                }

                demandeTrouvee = true;
                break;
            }

            if (demandeTrouvee) {
                double score = calculerScore(
                        organisation, financier, donMateriel);

                if (score > meilleurScore) {
                    meilleurScore = score;
                    meilleureOrganisation = organisation;
                }
            }
        }

        if (meilleureOrganisation == null) {
            throw new IllegalArgumentException(
                    "Aucune organisation prioritaire n'a été trouvée.");
        }

        return meilleureOrganisation;
    }

    // Vérifier si le matériel correspond au besoin
    private boolean correspondAuBesoin(
            DemandeAide demande,
            DonMateriel don) {

        if (don == null || don.getDesignation() == null) {
            return false;
        }

        String designation = don.getDesignation().toLowerCase();

        String titre = demande.getTitre() == null
                ? "" : demande.getTitre().toLowerCase();

        String description = demande.getDescriptionSituation() == null
                ? "" : demande.getDescriptionSituation().toLowerCase();

        return titre.contains(designation)
                || description.contains(designation);
    }

    // Calculer le score de priorité sur 100
    private double calculerScore(
            OrganisationPartenaire organisation,
            boolean financier,
            DonMateriel donMateriel) {

        List<DemandeAide> demandes =
                demandeRepository.findByOrganisationPartenaireId(
                        organisation.getId());

        double meilleurScore = 0;

        for (DemandeAide demande : demandes) {

            if (demande.getStatut() != StatutDemande.VALIDEE) {
                continue;
            }

            if (demande.getTypeDemandeAide() == null) {
                continue;
            }

            if (financier) {
                if (!demande.getTypeDemandeAide().name()
                        .equals("FINANCIERE")) {
                    continue;
                }

                double necessaire =
                        demande.getMontantNecessaire() == null
                                ? 0 : demande.getMontantNecessaire();

                double collecte =
                        demande.getMontantCollecte() == null
                                ? 0 : demande.getMontantCollecte();

                if (necessaire <= collecte) {
                    continue;
                }
            } else {
                if (!demande.getTypeDemandeAide().name()
                        .equals("MATERIELLE")) {
                    continue;
                }

                if (!correspondAuBesoin(demande, donMateriel)) {
                    continue;
                }
            }

            double score = 25;

            // Urgence
            if (demande.getNiveauUrgence() != null) {
                String urgence = demande.getNiveauUrgence().name();

                if (urgence.equals("FORTE")) {
                    score += 30;
                } else if (urgence.equals("MOYENNE")) {
                    score += 20;
                } else {
                    score += 10;
                }
            }

            // Vulnérabilité du bénéficiaire
            if (demande.getBeneficiaire() != null
                    && demande.getBeneficiaire().getTypeBeneficiaire() != null) {

                String type = demande.getBeneficiaire()
                        .getTypeBeneficiaire().name();

                if (type.contains("DEPLACE")
                        || type.contains("HANDICAP")) {
                    score += 20;
                } else {
                    score += 10;
                }
            }

            // Historique des attributions
            List<AttributionDonLibre> historiques =
                    attributionRepository.findByOrganisationPartenaireId(
                            organisation.getId());

            int nombreDonsComparables = 0;

            for (AttributionDonLibre historique : historiques) {
                if (financier && historique.getDonFinancier() != null) {
                    nombreDonsComparables++;
                }

                if (!financier && historique.getDonMateriel() != null) {
                    nombreDonsComparables++;
                }
            }

            if (nombreDonsComparables == 0) {
                score += 15;
            } else if (nombreDonsComparables == 1) {
                score += 10;
            } else {
                score += 5;
            }

            // Nombre de personnes concernées
            Integer nombrePersonnes = demande.getNombrePersonne();

            if (nombrePersonnes != null && nombrePersonnes >= 10) {
                score += 10;
            } else if (nombrePersonnes != null && nombrePersonnes >= 5) {
                score += 5;
            }

            if (score > meilleurScore) {
                meilleurScore = score;
            }
        }

        return Math.min(meilleurScore, 100);
    }

    // Vérifier que l'organisation choisie est prioritaire
    private void verifierOrganisation(
            Integer organisationId,
            OrganisationPartenaire organisationPrioritaire) {

        if (organisationId == null) {
            throw new IllegalArgumentException(
                    "L'identifiant de l'organisation est obligatoire.");
        }

        if (!organisationId.equals(organisationPrioritaire.getId())) {
            throw new IllegalArgumentException(
                    "Vous devez choisir l'organisation prioritaire.");
        }
    }

    // Consulter une attribution
    @Override
    @Transactional(readOnly = true)
    public AttributionDonLibreResponseDTO getById(Integer id) {

        AttributionDonLibre attribution =
                attributionRepository.findById(id)
                        .orElseThrow(() -> new EntityNotFoundException(
                                "Attribution introuvable."));

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur instanceof Admin) {
            return mapper.toDTO(attribution);
        }

        if (utilisateur instanceof OrganisationPartenaire) {

            OrganisationPartenaire organisation =
                    (OrganisationPartenaire) utilisateur;

            if (!attribution.getOrganisationPartenaire().getId()
                    .equals(organisation.getId())) {

                throw new AccessDeniedException(
                        "Vous ne pouvez consulter que les attributions de votre organisation.");
            }

            return mapper.toDTO(attribution);
        }

        throw new AccessDeniedException(
                "Vous n'avez pas le droit de consulter cette attribution.");
    }

    // Consulter toutes les attributions
    @Override
    @Transactional(readOnly = true)
    public List<AttributionDonLibreResponseDTO> getAll() {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        List<AttributionDonLibre> attributions;

        if (utilisateur instanceof Admin) {

            attributions = attributionRepository.findAll();

        } else if (utilisateur instanceof OrganisationPartenaire) {

            OrganisationPartenaire organisation =
                    (OrganisationPartenaire) utilisateur;

            attributions =
                    attributionRepository.findByOrganisationPartenaireId(
                            organisation.getId());

        } else {

            throw new AccessDeniedException(
                    "Vous n'avez pas le droit de consulter les attributions.");
        }

        return attributions.stream()
                .map(mapper::toDTO)
                .toList();
    }

    // Consulter les attributions d'une organisation
    @Override
    @Transactional(readOnly = true)
    public List<AttributionDonLibreResponseDTO> getByOrganisation(
            Integer organisationPartenaireId) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur instanceof Admin) {

            // ADMIN peut consulter toutes les organisations.

        } else if (utilisateur instanceof OrganisationPartenaire) {

            // ORGANISATIONPARTENAIRE : uniquement sa propre organisation.
            OrganisationPartenaire organisation =
                    (OrganisationPartenaire) utilisateur;

            if (!organisation.getId().equals(organisationPartenaireId)) {
                throw new AccessDeniedException(
                        "Vous ne pouvez consulter que les attributions de votre organisation.");
            }

        } else {

            throw new AccessDeniedException(
                    "Vous n'avez pas le droit de consulter ces attributions.");
        }

        List<AttributionDonLibre> attributions =
                attributionRepository.findByOrganisationPartenaireId(
                        organisationPartenaireId);

        return attributions.stream()
                .map(mapper::toDTO)
                .toList();
    }

    // Consulter l'organisation prioritaire avant l'attribution.
    // La consultation reste possible même si le don est épuisé.
    @Override
    @Transactional(readOnly = true)
    public OrganisationPrioritaireResponseDTO trouverOrganisationPrioritaire(
            Integer donFinancierId,
            Integer donMaterielId) {

        verifierAdminConnecte();

        boolean financier = donFinancierId != null;
        boolean materiel = donMaterielId != null;

        if (financier == materiel) {
            throw new IllegalArgumentException(
                    "Choisissez un seul don : financier ou matériel.");
        }

        OrganisationPartenaire organisation;
        double score;

        if (financier) {
            DonFinancier don = donFinancierRepository.findById(donFinancierId)
                    .orElseThrow(() -> new EntityNotFoundException(
                            "Don financier introuvable."));

            if (don.getDemandeAide() != null) {
                throw new IllegalArgumentException(
                        "Ce don n'est pas un don libre.");
            }

            boolean paiementConfirme =
                    paiementRepository.existsByDonFinancier_IdAndStatut(
                            don.getId(), StatutPaiement.CONFIRME);

            if (!paiementConfirme) {
                throw new IllegalArgumentException(
                        "Le paiement n'est pas confirmé.");
            }

            // Pas de vérification du solde dans la consultation.
            organisation = trouverOrganisationPrioritaire(true, null);
            score = calculerScore(organisation, true, null);

        } else {
            DonMateriel don = donMaterielRepository.findById(donMaterielId)
                    .orElseThrow(() -> new EntityNotFoundException(
                            "Don matériel introuvable."));

            if (don.getDemandeAide() != null) {
                throw new IllegalArgumentException(
                        "Ce don n'est pas un don libre.");
            }

            if (don.getStatutReception() != StatutReception.RECU) {
                throw new IllegalArgumentException(
                        "Le don matériel doit être réceptionné.");
            }

            // Pas de vérification du stock dans la consultation.
            organisation = trouverOrganisationPrioritaire(false, don);
            score = calculerScore(organisation, false, don);
        }

        return new OrganisationPrioritaireResponseDTO(
                organisation.getId(),
                organisation.getNomOrganisation(),
                score
        );
    }

    // Récupérer et vérifier l'administrateur connecté
    private Admin verifierAdminConnecte() {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (!(utilisateur instanceof Admin)) {
            throw new AccessDeniedException(
                    "Seul un administrateur peut effectuer cette opération.");
        }

        return (Admin) utilisateur;
    }
}