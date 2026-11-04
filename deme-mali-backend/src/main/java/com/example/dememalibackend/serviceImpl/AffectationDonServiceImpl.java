
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.*;
import com.example.dememalibackend.dto.AffectationDonRequestDTO;
import com.example.dememalibackend.dto.AffectationDonResponseDTO;
import com.example.dememalibackend.entity.*;
import com.example.dememalibackend.mappers.AffectationDonMapper;
import com.example.dememalibackend.repository.*;
import com.example.dememalibackend.service.AffectationDonService;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

@Service
@Transactional
public class AffectationDonServiceImpl implements AffectationDonService {

    private final AffectationDonRepository affectationRepository;
    private final DonFinancierRepository donFinancierRepository;
    private final PaiementDonRepository paiementDonRepository;
    private final DemandeAideRepository demandeAideRepository;
    private final BeneficiaireRepository beneficiaireRepository;
    private final OrganisationPartenaireRepository organisationRepository;
    private final AffectationDonMapper mapper;
    private final CustomUserDetailsService customUserDetailsService;

    public AffectationDonServiceImpl(
            AffectationDonRepository affectationRepository,
            DonFinancierRepository donFinancierRepository,
            PaiementDonRepository paiementDonRepository,
            DemandeAideRepository demandeAideRepository,
            BeneficiaireRepository beneficiaireRepository,
            OrganisationPartenaireRepository organisationRepository,
            AffectationDonMapper mapper,
            CustomUserDetailsService customUserDetailsService) {

        this.affectationRepository = affectationRepository;
        this.donFinancierRepository = donFinancierRepository;
        this.paiementDonRepository = paiementDonRepository;
        this.demandeAideRepository = demandeAideRepository;
        this.beneficiaireRepository = beneficiaireRepository;
        this.organisationRepository = organisationRepository;
        this.mapper = mapper;
        this.customUserDetailsService = customUserDetailsService;
    }

    /*
     * Vérifie si une affectation appartient à l'organisation connectée.
     */
    private boolean appartientAOrganisation(
            AffectationDon affectation,
            Utilisateur utilisateur) {

        return utilisateur instanceof OrganisationPartenaire
                && affectation.getOrganisationPartenaire() != null
                && Objects.equals(
                affectation.getOrganisationPartenaire().getId(),
                utilisateur.getId()
        );
    }

    /*
     * Vérifie si l'affectation provient d'un don du donateur connecté.
     */
    private boolean appartientAuDonateur(
            AffectationDon affectation,
            Utilisateur utilisateur) {

        return affectation.getDonFinancier() != null
                && affectation.getDonFinancier().getDonateur() != null
                && Objects.equals(
                affectation.getDonFinancier().getDonateur().getId(),
                utilisateur.getId()
        );
    }

    /*
     * Vérifie si l'affectation concerne le bénéficiaire connecté.
     * Le bénéficiaire peut être directement destinataire
     * ou être associé à la demande d'aide.
     */
    private boolean concerneBeneficiaire(
            AffectationDon affectation,
            Utilisateur utilisateur) {

        boolean beneficiaireDirect =
                affectation.getBeneficiaire() != null
                        && Objects.equals(
                        affectation.getBeneficiaire().getId(),
                        utilisateur.getId()
                );

        boolean beneficiaireParDemande =
                affectation.getDemandeAide() != null
                        && affectation.getDemandeAide().getBeneficiaire() != null
                        && Objects.equals(
                        affectation.getDemandeAide()
                                .getBeneficiaire().getId(),
                        utilisateur.getId()
                );

        return beneficiaireDirect || beneficiaireParDemande;
    }

    /*
     * Vérifie les droits de consultation d'une affectation.
     */
    private void verifierAccesAffectation(
            AffectationDon affectation,
            Utilisateur utilisateur) {

        if (utilisateur.getRole() == RoleEnum.ADMIN) {
            return;
        }

        if (utilisateur.getRole() == RoleEnum.ORGANISATIONPARTENAIRE
                && appartientAOrganisation(affectation, utilisateur)) {
            return;
        }

        if (utilisateur.getRole() == RoleEnum.DONATEUR
                && appartientAuDonateur(affectation, utilisateur)) {
            return;
        }

        if (utilisateur.getRole() == RoleEnum.BENEFICIARE
                && concerneBeneficiaire(affectation, utilisateur)) {
            return;
        }

        throw new AccessDeniedException(
                "Vous n'avez pas le droit de consulter cette affectation."
        );
    }

    /*
     * Crée une affectation financière.
     */
    @Override
    public AffectationDonResponseDTO creer(
            AffectationDonRequestDTO dto,
            Integer organisationPartenaireId) {

        if (dto == null
                || dto.getDonFinancierId() == null
                || organisationPartenaireId == null) {
            throw new IllegalArgumentException(
                    "Le don financier et l'organisation sont obligatoires.");
        }

        // Vérifier que l'organisation connectée crée pour elle-même.
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur.getRole() != RoleEnum.ORGANISATIONPARTENAIRE
                || !(utilisateur instanceof OrganisationPartenaire)
                || !Objects.equals(utilisateur.getId(), organisationPartenaireId)) {

            throw new AccessDeniedException(
                    "Vous ne pouvez pas effectuer une affectation pour une autre organisation."
            );
        }

        if (dto.getMontantAffecte() == null
                || !Double.isFinite(dto.getMontantAffecte())
                || dto.getMontantAffecte() <= 0) {
            throw new IllegalArgumentException(
                    "Le montant affecté doit être positif et valide.");
        }

        boolean demandeRenseignee = dto.getDemandeAideId() != null;
        boolean beneficiaireRenseigne = dto.getBeneficiaireId() != null;

        if (demandeRenseignee == beneficiaireRenseigne) {
            throw new IllegalArgumentException(
                    "Renseignez une demande d'aide ou un bénéficiaire, pas les deux.");
        }

        OrganisationPartenaire organisation =
                organisationRepository.findById(organisationPartenaireId)
                        .orElseThrow(() -> new IllegalArgumentException(
                                "Organisation partenaire introuvable."));

        if (organisation.getStatutValidation() != StatutValidation.VALIDEE) {
            throw new IllegalArgumentException(
                    "L'organisation partenaire n'est pas validée.");
        }

        DonFinancier don = donFinancierRepository
                .findByIdForUpdate(dto.getDonFinancierId())
                .orElseThrow(() -> new IllegalArgumentException(
                        "Don financier introuvable."));

        // Ce service traite uniquement les dons financiers libres.
        if (don.getDemandeAide() != null) {
            throw new IllegalArgumentException(
                    "Ce don est déjà lié à une demande. "
                            + "Seuls les dons financiers libres peuvent être affectés ici.");
        }

        boolean paiementConfirme =
                paiementDonRepository.existsByDonFinancier_IdAndStatut(
                        don.getId(),
                        StatutPaiement.CONFIRME);

        if (!paiementConfirme) {
            throw new IllegalArgumentException(
                    "Le don financier doit avoir un paiement confirmé.");
        }

        DemandeAide demande = null;
        Beneficiaire beneficiaire = null;

        if (demandeRenseignee) {

            demande = demandeAideRepository
                    .findByIdForUpdate(dto.getDemandeAideId())
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Demande d'aide introuvable."));

            if (demande.getStatut() != StatutDemande.VALIDEE) {
                throw new IllegalArgumentException(
                        "La demande d'aide doit être validée.");
            }

            if (demande.getTypeDemandeAide() != TypeDemandeAide.FINANCIERE) {
                throw new IllegalArgumentException(
                        "L'affectation financière exige une demande financière.");
            }

            if (demande.getOrganisationPartenaire() == null
                    || !demande.getOrganisationPartenaire().getId()
                    .equals(organisation.getId())) {
                throw new IllegalArgumentException(
                        "Cette demande ne relève pas de votre organisation.");
            }

        } else {

            beneficiaire = beneficiaireRepository
                    .findById(dto.getBeneficiaireId())
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Bénéficiaire introuvable."));

            if (beneficiaire.getStatut() != StatutBeneficiaire.ACCEPTE) {
                throw new IllegalArgumentException(
                        "Le bénéficiaire doit être accepté.");
            }

            if (beneficiaire.getOrganisationPartenaire() == null
                    || !beneficiaire.getOrganisationPartenaire().getId()
                    .equals(organisation.getId())) {
                throw new IllegalArgumentException(
                        "Ce bénéficiaire ne relève pas de votre organisation.");
            }
        }

        Double montantDejaAffecte =
                affectationRepository.calculerMontantAffecte(don.getId());

        if (montantDejaAffecte == null) {
            montantDejaAffecte = 0.0;
        }

        double montantDisponible = don.getMontant() - montantDejaAffecte;

        if (dto.getMontantAffecte() > montantDisponible + 0.000001) {
            throw new IllegalArgumentException(
                    "Montant insuffisant. Solde disponible : "
                            + Math.max(0.0, montantDisponible) + " FCFA.");
        }

        AffectationDon affectation = AffectationDon.builder()
                .donFinancier(don)
                .demandeAide(demande)
                .beneficiaire(beneficiaire)
                .organisationPartenaire(organisation)
                .montantAffecte(dto.getMontantAffecte())
                .dateAffectation(LocalDate.now())
                .build();

        AffectationDon enregistree =
                affectationRepository.save(affectation);

        return mapper.toDTO(enregistree);
    }

    /*
     * Récupère une affectation par son identifiant.
     */
    @Override
    @Transactional(readOnly = true)
    public AffectationDonResponseDTO getById(Integer id) {

        AffectationDon affectation = affectationRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Affectation introuvable : " + id));

        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        verifierAccesAffectation(affectation, utilisateur);

        return mapper.toDTO(affectation);
    }

    /*
     * Récupère toutes les affectations.
     * ADMIN : toutes.
     * ORGANISATIONPARTENAIRE : uniquement celles de son organisation.
     */
    @Override
    @Transactional(readOnly = true)
    public List<AffectationDonResponseDTO> getAll() {

        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        List<AffectationDon> affectations = affectationRepository.findAll();

        if (utilisateur.getRole() == RoleEnum.ADMIN) {
            return affectations.stream()
                    .map(mapper::toDTO)
                    .toList();
        }

        if (utilisateur.getRole() == RoleEnum.ORGANISATIONPARTENAIRE
                && utilisateur instanceof OrganisationPartenaire) {

            return affectations.stream()
                    .filter(a -> appartientAOrganisation(a, utilisateur))
                    .map(mapper::toDTO)
                    .toList();
        }

        throw new AccessDeniedException(
                "Vous n'avez pas le droit de consulter toutes les affectations."
        );
    }

    /*
     * Récupère les affectations d'un don financier.
     */
    @Override
    @Transactional(readOnly = true)
    public List<AffectationDonResponseDTO> getByDon(
            Integer donFinancierId) {

        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        DonFinancier don = donFinancierRepository.findById(donFinancierId)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Don financier introuvable."));

        List<AffectationDon> affectations =
                affectationRepository.findByDonFinancierId(donFinancierId);

        if (utilisateur.getRole() == RoleEnum.ADMIN) {
            return affectations.stream()
                    .map(mapper::toDTO)
                    .toList();
        }

        if (utilisateur.getRole() == RoleEnum.ORGANISATIONPARTENAIRE
                && utilisateur instanceof OrganisationPartenaire) {

            return affectations.stream()
                    .filter(a -> appartientAOrganisation(a, utilisateur))
                    .map(mapper::toDTO)
                    .toList();
        }

        if (utilisateur.getRole() == RoleEnum.DONATEUR
                && utilisateur instanceof Donateur) {

            if (don.getDonateur() == null
                    || !Objects.equals(
                    don.getDonateur().getId(),
                    utilisateur.getId())) {

                throw new AccessDeniedException(
                        "Vous ne pouvez consulter que les affectations de vos propres dons."
                );
            }

            return affectations.stream()
                    .map(mapper::toDTO)
                    .toList();
        }

        throw new AccessDeniedException(
                "Vous n'avez pas le droit de consulter ces affectations."
        );
    }

    /*
     * Récupère les affectations liées à une demande d'aide.
     */
    @Override
    @Transactional(readOnly = true)
    public List<AffectationDonResponseDTO> getByDemande(
            Integer demandeAideId) {

        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        DemandeAide demande = demandeAideRepository.findById(demandeAideId)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Demande d'aide introuvable."));

        List<AffectationDon> affectations =
                affectationRepository.findByDemandeAideId(demandeAideId);

        if (utilisateur.getRole() == RoleEnum.ADMIN) {
            return affectations.stream()
                    .map(mapper::toDTO)
                    .toList();
        }

        if (utilisateur.getRole() == RoleEnum.ORGANISATIONPARTENAIRE
                && utilisateur instanceof OrganisationPartenaire) {

            if (demande.getOrganisationPartenaire() == null
                    || !Objects.equals(
                    demande.getOrganisationPartenaire().getId(),
                    utilisateur.getId())) {

                throw new AccessDeniedException(
                        "Cette demande ne relève pas de votre organisation."
                );
            }

            return affectations.stream()
                    .filter(a -> appartientAOrganisation(a, utilisateur))
                    .map(mapper::toDTO)
                    .toList();
        }

        if (utilisateur.getRole() == RoleEnum.DONATEUR
                && utilisateur instanceof Donateur) {

            return affectations.stream()
                    .filter(a -> appartientAuDonateur(a, utilisateur))
                    .map(mapper::toDTO)
                    .toList();
        }

        if (utilisateur.getRole() == RoleEnum.BENEFICIARE
                && utilisateur instanceof Beneficiaire) {

            if (demande.getBeneficiaire() == null
                    || !Objects.equals(
                    demande.getBeneficiaire().getId(),
                    utilisateur.getId())) {

                throw new AccessDeniedException(
                        "Vous ne pouvez consulter que les affectations liées à vos demandes."
                );
            }

            return affectations.stream()
                    .map(mapper::toDTO)
                    .toList();
        }

        throw new AccessDeniedException(
                "Vous n'avez pas le droit de consulter ces affectations."
        );
    }
    //les affections de l'organisation connecte
    /*
     * Récupère uniquement les affectations financières
     * effectuées par l'organisation partenaire connectée.
     */
    @Override
    @Transactional(readOnly = true)
    public List<AffectationDonResponseDTO> getMesAffectations() {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur.getRole() != RoleEnum.ORGANISATIONPARTENAIRE
                || !(utilisateur instanceof OrganisationPartenaire)) {

            throw new AccessDeniedException(
                    "Seule une organisation partenaire peut consulter ses affectations."
            );
        }

        List<AffectationDon> affectations =
                affectationRepository.findByOrganisationPartenaireId(
                        utilisateur.getId()
                );

        return affectations.stream()
                .map(mapper::toDTO)
                .toList();
    }
}
