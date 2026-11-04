package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.*;
import com.example.dememalibackend.dto.AffectationDonMaterielRequestDTO;
import com.example.dememalibackend.entity.*;
import com.example.dememalibackend.repository.*;
import com.example.dememalibackend.service.AffectationDonMaterielService;
import com.example.dememalibackend.serviceImpl.CustomUserDetailsService;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

@Service
public class AffectationDonMaterielServiceImpl implements AffectationDonMaterielService {

    private final AffectationDonMaterielRepository affectationRepository;
    private final DonMaterielRepository donMaterielRepository;
    private final DemandeAideRepository demandeAideRepository;
    private final BeneficiaireRepository beneficiaireRepository;
    private final OrganisationPartenaireRepository organisationRepository;
    private final CustomUserDetailsService customUserDetailsService;

    public AffectationDonMaterielServiceImpl(
            AffectationDonMaterielRepository affectationRepository,
            DonMaterielRepository donMaterielRepository,
            DemandeAideRepository demandeAideRepository,
            BeneficiaireRepository beneficiaireRepository,
            OrganisationPartenaireRepository organisationRepository,
            CustomUserDetailsService customUserDetailsService) {
        this.affectationRepository = affectationRepository;
        this.donMaterielRepository = donMaterielRepository;
        this.demandeAideRepository = demandeAideRepository;
        this.beneficiaireRepository = beneficiaireRepository;
        this.organisationRepository = organisationRepository;
        this.customUserDetailsService = customUserDetailsService;
    }

    // Récupérer l'organisation connectée
    private OrganisationPartenaire getOrganisationConnectee() {
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur.getRole() != RoleEnum.ORGANISATIONPARTENAIRE
                || !(utilisateur instanceof OrganisationPartenaire)) {
            throw new AccessDeniedException("Cette opération est réservée aux organisations partenaires.");
        }

        return (OrganisationPartenaire) utilisateur;
    }

    @Override
    @Transactional
    public AffectationDonMateriel affecter(AffectationDonMaterielRequestDTO dto) {

        if (dto == null || dto.getDonMaterielId() == null || dto.getOrganisationPartenaireId() == null) {
            throw new IllegalArgumentException("Le don matériel et l'organisation sont obligatoires.");
        }

        // Vérifier que l'organisation connectée affecte pour elle-même
        OrganisationPartenaire organisationConnectee = getOrganisationConnectee();

        if (!Objects.equals(organisationConnectee.getId(), dto.getOrganisationPartenaireId())) {
            throw new AccessDeniedException("Vous ne pouvez pas effectuer une affectation pour une autre organisation.");
        }

        if (dto.getQuantiteAffectee() == null || dto.getQuantiteAffectee() <= 0) {
            throw new IllegalArgumentException("La quantité affectée doit être positive.");
        }

        // Une seule destination : demande OU bénéficiaire
        boolean demandeRenseignee = dto.getDemandeAideId() != null;
        boolean beneficiaireRenseigne = dto.getBeneficiaireId() != null;

        if (demandeRenseignee == beneficiaireRenseigne) {
            throw new IllegalArgumentException("Renseignez une demande d'aide ou un bénéficiaire, pas les deux.");
        }

        // Vérifier l'organisation partenaire
        OrganisationPartenaire organisation = organisationRepository.findById(dto.getOrganisationPartenaireId())
                .orElseThrow(() -> new IllegalArgumentException("Organisation partenaire introuvable."));

        if (organisation.getStatutValidation() != StatutValidation.VALIDEE) {
            throw new IllegalArgumentException("L'organisation partenaire n'est pas validée.");
        }

        // Verrouiller le don pendant la transaction
        DonMateriel don = donMaterielRepository.findByIdForUpdate(dto.getDonMaterielId())
                .orElseThrow(() -> new IllegalArgumentException("Don matériel introuvable."));

        // Le service traite uniquement les dons réceptionnés
        if (don.getStatutReception() != StatutReception.RECU) {
            throw new IllegalArgumentException("Le don matériel doit être réceptionné avant son affectation.");
        }

        // Ce service est réservé aux dons libres
        if (don.getDemandeAide() != null) {
            throw new IllegalArgumentException("Ce don matériel est déjà lié à une demande. "
                    + "Seuls les dons libres peuvent être affectés ici.");
        }

        DemandeAide demande = null;
        Beneficiaire beneficiaire = null;

        if (demandeRenseignee) {
            demande = demandeAideRepository.findByIdForUpdate(dto.getDemandeAideId())
                    .orElseThrow(() -> new IllegalArgumentException("Demande d'aide introuvable."));

            if (demande.getStatut() != StatutDemande.VALIDEE) {
                throw new IllegalArgumentException("La demande d'aide doit être validée.");
            }

            if (demande.getTypeDemandeAide() != TypeDemandeAide.MATERIELLE) {
                throw new IllegalArgumentException("Un don matériel ne peut être affecté "
                        + "qu'à une demande matérielle.");
            }

            if (demande.getOrganisationPartenaire() == null
                    || !demande.getOrganisationPartenaire().getId().equals(organisation.getId())) {
                throw new IllegalArgumentException("Cette demande ne relève pas de votre organisation.");
            }

        } else {
            beneficiaire = beneficiaireRepository.findById(dto.getBeneficiaireId())
                    .orElseThrow(() -> new IllegalArgumentException("Bénéficiaire introuvable."));

            if (beneficiaire.getStatut() != StatutBeneficiaire.ACCEPTE) {
                throw new IllegalArgumentException("Le bénéficiaire doit être accepté.");
            }

            if (beneficiaire.getOrganisationPartenaire() == null
                    || !beneficiaire.getOrganisationPartenaire().getId().equals(organisation.getId())) {
                throw new IllegalArgumentException("Ce bénéficiaire ne relève pas de votre organisation.");
            }
        }

        // Quantité réellement reçue
        int quantiteRecue = don.getQuantiteRecue() == null ? 0 : don.getQuantiteRecue();

        Integer dejaAffectee = affectationRepository.calculerQuantiteAffectee(don.getId());

        if (dejaAffectee == null) {
            dejaAffectee = 0;
        }

        int disponible = quantiteRecue - dejaAffectee;

        if (disponible < 0 || dto.getQuantiteAffectee() > disponible) {
            throw new IllegalArgumentException("Quantité insuffisante. Il reste "
                    + Math.max(0, disponible) + " " + don.getUnite() + ".");
        }

        AffectationDonMateriel affectation = AffectationDonMateriel.builder()
                .donMateriel(don)
                .demandeAide(demande)
                .beneficiaire(beneficiaire)
                .organisationPartenaire(organisation)
                .quantiteAffectee(dto.getQuantiteAffectee())
                .dateAffectation(LocalDate.now())
                .build();

        return affectationRepository.save(affectation);
    }

    // ADMIN uniquement : consulter toutes les affectations
    @Override
    @Transactional(readOnly = true)
    public List<AffectationDonMateriel> getAll() {
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur.getRole() != RoleEnum.ADMIN) {
            throw new AccessDeniedException("Seul l'administrateur peut consulter toutes les affectations.");
        }

        return affectationRepository.findAll();
    }

    // ORGANISATIONPARTENAIRE : consulter ses propres affectations
    @Override
    @Transactional(readOnly = true)
    public List<AffectationDonMateriel> getMesAffectations() {
        OrganisationPartenaire organisation = getOrganisationConnectee();

        return affectationRepository.findByOrganisationPartenaireId(organisation.getId());
    }

    // ADMIN, ORGANISATIONPARTENAIRE ou DONATEUR
    @Override
    @Transactional(readOnly = true)
    public List<AffectationDonMateriel> getByDonMateriel(Integer donMaterielId) {
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        List<AffectationDonMateriel> affectations = affectationRepository.findByDonMaterielId(donMaterielId);

        // ADMIN : toutes les affectations du don
        if (utilisateur.getRole() == RoleEnum.ADMIN) {
            return affectations;
        }

        // ORGANISATIONPARTENAIRE : uniquement ses affectations
        if (utilisateur.getRole() == RoleEnum.ORGANISATIONPARTENAIRE
                && utilisateur instanceof OrganisationPartenaire) {
            return affectations.stream()
                    .filter(a -> a.getOrganisationPartenaire() != null
                            && Objects.equals(a.getOrganisationPartenaire().getId(), utilisateur.getId()))
                    .toList();
        }

        // DONATEUR : uniquement les affectations de son propre don
        if (utilisateur.getRole() == RoleEnum.DONATEUR && utilisateur instanceof Donateur) {
            DonMateriel don = donMaterielRepository.findById(donMaterielId)
                    .orElseThrow(() -> new IllegalArgumentException("Don matériel introuvable."));

            if (don.getDonateur() == null
                    || !Objects.equals(don.getDonateur().getId(), utilisateur.getId())) {
                throw new AccessDeniedException("Vous ne pouvez consulter que les affectations de vos propres dons.");
            }

            return affectations;
        }

        throw new AccessDeniedException("Vous n'avez pas le droit de consulter ces affectations.");
    }

    // ADMIN, ORGANISATIONPARTENAIRE ou BENEFICIARE
    @Override
    @Transactional(readOnly = true)
    public List<AffectationDonMateriel> getByBeneficiaire(Integer beneficiaireId) {
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        Beneficiaire beneficiaire = beneficiaireRepository.findById(beneficiaireId)
                .orElseThrow(() -> new IllegalArgumentException("Bénéficiaire introuvable."));

        List<AffectationDonMateriel> affectations = affectationRepository.findByBeneficiaireId(beneficiaireId);

        // ADMIN : consulter toutes les affectations du bénéficiaire
        if (utilisateur.getRole() == RoleEnum.ADMIN) {
            return affectations;
        }

        // ORGANISATIONPARTENAIRE : consulter les affectations des bénéficiaires appartenant à son organisation
        if (utilisateur.getRole() == RoleEnum.ORGANISATIONPARTENAIRE
                && utilisateur instanceof OrganisationPartenaire) {
            if (beneficiaire.getOrganisationPartenaire() == null
                    || !Objects.equals(beneficiaire.getOrganisationPartenaire().getId(), utilisateur.getId())) {
                throw new AccessDeniedException("Ce bénéficiaire ne relève pas de votre organisation.");
            }

            return affectations.stream()
                    .filter(a -> a.getOrganisationPartenaire() != null
                            && Objects.equals(a.getOrganisationPartenaire().getId(), utilisateur.getId()))
                    .toList();
        }

        // BENEFICIARE : consulter uniquement ses propres affectations
        if (utilisateur.getRole() == RoleEnum.BENEFICIARE && utilisateur instanceof Beneficiaire) {
            if (!Objects.equals(beneficiaireId, utilisateur.getId())) {
                throw new AccessDeniedException("Vous ne pouvez consulter que vos propres affectations.");
            }

            return affectations;
        }

        throw new AccessDeniedException("Vous n'avez pas le droit de consulter ces affectations.");
    }

}