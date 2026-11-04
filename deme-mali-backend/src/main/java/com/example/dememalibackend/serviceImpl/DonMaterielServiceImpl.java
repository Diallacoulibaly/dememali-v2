
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.*;
import com.example.dememalibackend.dto.DonMaterielRequestDTO;
import com.example.dememalibackend.dto.DonMaterielResponseDTO;
import com.example.dememalibackend.entity.*;
import com.example.dememalibackend.mappers.DonMaterielMapper;
import com.example.dememalibackend.repository.*;
import com.example.dememalibackend.service.DonMaterielService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DonMaterielServiceImpl implements DonMaterielService {

    private final DonMaterielRepository donMaterielRepository;
    private final DonateurRepository donateurRepository;
    private final DemandeAideRepository demandeAideRepository;
    private final OrganisationPartenaireRepository organisationPartenaireRepository;
    private final DonMaterielMapper donMaterielMapper;
    private final DonFinancierRepository donFinancierRepository;
    private final PaiementDonRepository paiementDonRepository;
    private final RapportTechniqueRepository rapportTechniqueRepository;
    private final AffectationDonMaterielRepository affectationDonMaterielRepository;
    private final CustomUserDetailsService customUserDetailsService;

    // Vérifications de sécurité

    private boolean estAdmin() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null && authentication.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
    }

    private Utilisateur getUtilisateurConnecte() {
        return customUserDetailsService.getUtilisateurConnecte();
    }

    private Donateur getDonateurConnecte() {
        Utilisateur utilisateur = getUtilisateurConnecte();
        if (!(utilisateur instanceof Donateur donateur)) {
            throw new AccessDeniedException("Accès réservé aux donateurs.");
        }
        return donateur;
    }

    private OrganisationPartenaire getOrganisationConnectee() {
        Utilisateur utilisateur = getUtilisateurConnecte();
        if (!(utilisateur instanceof OrganisationPartenaire organisation)) {
            throw new AccessDeniedException("Accès réservé aux organisations partenaires.");
        }
        return organisation;
    }

    private void verifierOrganisationDestinataire(DonMateriel don) {
        if (estAdmin()) return;

        OrganisationPartenaire organisation = getOrganisationConnectee();

        boolean donDirect = don.getOrganisationPartenaire() != null
                && don.getOrganisationPartenaire().getId().equals(organisation.getId());

        boolean donViaDemande = don.getDemandeAide() != null
                && don.getDemandeAide().getOrganisationPartenaire() != null
                && don.getDemandeAide().getOrganisationPartenaire().getId()
                .equals(organisation.getId());

        if (!donDirect && !donViaDemande) {
            throw new AccessDeniedException("Ce don ne vous est pas destiné.");
        }
    }

    private DemandeAide verifierAccesDemande(Integer demandeAideId) {
        DemandeAide demande = demandeAideRepository.findById(demandeAideId)
                .orElseThrow(() -> new IllegalArgumentException("Demande d'aide introuvable."));

        if (estAdmin()) return demande;

        Utilisateur utilisateur = getUtilisateurConnecte();

        if (utilisateur instanceof OrganisationPartenaire organisation) {
            if (demande.getOrganisationPartenaire() == null
                    || !demande.getOrganisationPartenaire().getId().equals(organisation.getId())) {
                throw new AccessDeniedException("Cette demande ne dépend pas de votre organisation.");
            }
        } else if (utilisateur instanceof Beneficiaire beneficiaire) {
            if (demande.getBeneficiaire() == null
                    || !demande.getBeneficiaire().getId().equals(beneficiaire.getId())) {
                throw new AccessDeniedException("Cette demande ne vous appartient pas.");
            }
        } else if (!(utilisateur instanceof Donateur)) {
            throw new AccessDeniedException("Vous n'êtes pas autorisé à consulter cette demande.");
        }

        return demande;
    }

    // 1. Créer un don matériel

    @Override
    @Transactional
    public DonMaterielResponseDTO creer(DonMaterielRequestDTO dto) {

        if (dto == null || dto.getDesignation() == null
                || dto.getDesignation().isBlank()
                || dto.getQuantite() == null || dto.getQuantite() <= 0
                || dto.getUnite() == null || dto.getUnite().isBlank()
                || dto.getEtatMateriel() == null
                || dto.getDonateurId() == null) {
            throw new IllegalArgumentException("Les informations du don matériel sont invalides");
        }

        Donateur donateur = getDonateurConnecte();

        if (!donateur.getId().equals(dto.getDonateurId())) {
            throw new AccessDeniedException("Vous ne pouvez pas créer un don au nom d'un autre donateur.");
        }

        if (dto.getDemandeAideId() != null && dto.getOrganisationPartenaireId() != null) {
            throw new IllegalArgumentException(
                    "Un don matériel ne peut pas être destiné simultanément à une demande d'aide et à une organisation.");
        }

        OrganisationPartenaire organisation = null;

        if (dto.getOrganisationPartenaireId() != null) {
            organisation = organisationPartenaireRepository.findById(dto.getOrganisationPartenaireId())
                    .orElseThrow(() -> new IllegalArgumentException("Organisation partenaire introuvable"));
        }

        DonMateriel don = donMaterielMapper.toEntity(dto);
        don.setDonateur(donateur);
        don.setOrganisationPartenaire(organisation);

        if (dto.getDemandeAideId() != null) {

            DemandeAide demande = demandeAideRepository.findById(dto.getDemandeAideId())
                    .orElseThrow(() -> new IllegalArgumentException("Demande d'aide introuvable"));

            if (demande.getStatut() != StatutDemande.VALIDEE) {
                throw new IllegalStateException("La demande d'aide n'est pas validée");
            }

            if (demande.getTypeDemandeAide() == TypeDemandeAide.FINANCIERE) {
                throw new IllegalArgumentException(
                        "Cette demande est financière : les dons matériels ne sont pas autorisés");
            }

            DetailRapportTechnique detail = trouverDetailTechnique(
                    demande, don.getDesignation(), don.getUnite());

            int quantiteDejaRecue = calculerQuantiteRecue(
                    demande, detail.getDesignation(), detail.getUnite(), null);

            int quantiteRestante = detail.getQuantite() - quantiteDejaRecue;

            if (quantiteRestante <= 0) {
                throw new IllegalArgumentException(
                        "Ce besoin est déjà entièrement satisfait. Aucune quantité supplémentaire n'est nécessaire.");
            }

            if (don.getQuantite() > quantiteRestante) {
                throw new IllegalArgumentException(
                        "La quantité saisie dépasse le besoin restant. Vous pouvez encore donner "
                                + quantiteRestante + " " + detail.getUnite() + " maximum.");
            }

            don.setDemandeAide(demande);
        }

        don.setQuantiteRecue(0);
        don.setStatutReception(StatutReception.EN_ATTENTE);
        don.setDateReception(null);

        DonMateriel donEnregistre = donMaterielRepository.save(don);
        return donMaterielMapper.toResponseDTO(donEnregistre);
    }

    // 2. Consulter les dons d'un donateur

    @Override
    @Transactional(readOnly = true)
    public List<DonMaterielResponseDTO> getByDonateur(Integer donateurId) {

        if (!estAdmin() && !getDonateurConnecte().getId().equals(donateurId)) {
            throw new AccessDeniedException("Vous ne pouvez consulter que vos propres dons.");
        }

        return donMaterielRepository.findByDonateurId(donateurId)
                .stream()
                .map(donMaterielMapper::toResponseDTO)
                .toList();
    }

    // 3. Consulter les dons associés à une demande

    @Override
    @Transactional(readOnly = true)
    public List<DonMaterielResponseDTO> getByDemande(Integer demandeAideId) {

        verifierAccesDemande(demandeAideId);

        List<DonMateriel> dons = donMaterielRepository.findByDemandeAideId(demandeAideId);

        if (!estAdmin() && getUtilisateurConnecte() instanceof Donateur donateur) {
            dons = dons.stream()
                    .filter(don -> don.getDonateur() != null
                            && don.getDonateur().getId().equals(donateur.getId()))
                    .toList();
        }

        return dons.stream()
                .map(donMaterielMapper::toResponseDTO)
                .toList();
    }

    // 4. Confirmer la réception du matériel

    @Override
    @Transactional
    public DonMaterielResponseDTO confirmerReception(Integer donId, Integer quantiteRecue) {

        if (donId == null) {
            throw new IllegalArgumentException("L'identifiant du don est obligatoire");
        }

        if (quantiteRecue == null || quantiteRecue <= 0) {
            throw new IllegalArgumentException("La quantité reçue doit être positive");
        }

        DonMateriel don = donMaterielRepository.findById(donId)
                .orElseThrow(() -> new IllegalArgumentException("Don matériel introuvable"));

        verifierOrganisationDestinataire(don);

        if (don.getStatutReception() != StatutReception.EN_ATTENTE
                && don.getStatutReception() != StatutReception.PARTIELLEMENT_RECU) {
            throw new IllegalStateException("Ce don ne peut plus être réceptionné.");
        }

        int dejaRecu = don.getQuantiteRecue() == null ? 0 : don.getQuantiteRecue();
        int quantiteRestanteDuDon = don.getQuantite() - dejaRecu;

        if (quantiteRecue > quantiteRestanteDuDon) {
            throw new IllegalArgumentException(
                    "La quantité reçue dépasse la quantité restante de ce don : " + quantiteRestanteDuDon);
        }

        int nouveauTotalDon = dejaRecu + quantiteRecue;
        DemandeAide demande = don.getDemandeAide();

        if (demande != null) {
            DetailRapportTechnique detail = trouverDetailTechnique(
                    demande, don.getDesignation(), don.getUnite());

            int quantiteRecueParLesAutresDons = calculerQuantiteRecue(
                    demande, detail.getDesignation(), detail.getUnite(), donId);

            int besoinRestant = detail.getQuantite() - quantiteRecueParLesAutresDons;

            if (besoinRestant <= 0) {
                throw new IllegalArgumentException(
                        "Ce besoin est déjà entièrement satisfait. Aucune quantité supplémentaire n'est nécessaire.");
            }

            if (quantiteRecue > besoinRestant) {
                throw new IllegalArgumentException(
                        "La quantité reçue dépasse le besoin restant. Il reste seulement "
                                + besoinRestant + " " + detail.getUnite() + " à réceptionner.");
            }
        }

        don.setQuantiteRecue(nouveauTotalDon);

        if (nouveauTotalDon < don.getQuantite()) {
            don.setStatutReception(StatutReception.PARTIELLEMENT_RECU);
        } else {
            don.setStatutReception(StatutReception.RECU);
        }

        don.setDateReception(LocalDate.now());

        DonMateriel donEnregistre = donMaterielRepository.save(don);

        if (demande != null) {
            recalculerStatutCollecte(demande);
        }

        return donMaterielMapper.toResponseDTO(donEnregistre);
    }

    // 5. Refuser un don matériel

    @Override
    @Transactional
    public DonMaterielResponseDTO refuser(Integer donId, String motifRefus) {

        if (donId == null) {
            throw new IllegalArgumentException("L'identifiant du don est obligatoire");
        }

        if (motifRefus == null || motifRefus.isBlank()) {
            throw new IllegalArgumentException("Le motif du refus est obligatoire");
        }

        DonMateriel don = donMaterielRepository.findById(donId)
                .orElseThrow(() -> new IllegalArgumentException("Don matériel introuvable"));

        verifierOrganisationDestinataire(don);

        StatutReception statut = don.getStatutReception();

        if (statut != StatutReception.EN_ATTENTE
                && statut != StatutReception.PARTIELLEMENT_RECU) {
            throw new IllegalStateException("Ce don ne peut plus être refusé.");
        }

        int quantiteRecue = don.getQuantiteRecue() == null ? 0 : don.getQuantiteRecue();
        int quantiteRestante = don.getQuantite() - quantiteRecue;

        if (quantiteRestante <= 0) {
            throw new IllegalStateException("Aucune quantité restante à refuser.");
        }

        don.setMotifRefus(motifRefus.trim());

        if (quantiteRecue == 0) {
            don.setStatutReception(StatutReception.REFUSE);
        } else {
            don.setStatutReception(StatutReception.PARTIELLEMENT_RECU);
        }

        DonMateriel donEnregistre = donMaterielRepository.save(don);
        return donMaterielMapper.toResponseDTO(donEnregistre);
    }

    // 6. Consulter les dons d'une organisation

    @Override
    @Transactional(readOnly = true)
    public List<DonMaterielResponseDTO> getByOrganisation(Integer organisationId) {

        if (!estAdmin() && !getOrganisationConnectee().getId().equals(organisationId)) {
            throw new AccessDeniedException("Vous ne pouvez consulter que les dons de votre organisation.");
        }

        return donMaterielRepository.findByOrganisation(organisationId)
                .stream()
                .map(donMaterielMapper::toResponseDTO)
                .toList();
    }

    // 7. Trouver le détail technique correspondant au matériel

    private DetailRapportTechnique trouverDetailTechnique(
            DemandeAide demande, String designation, String unite) {

        if (demande.getEtudeTerrain() == null
                || demande.getEtudeTerrain().getRapportBesoin() == null
                || demande.getEtudeTerrain().getRapportBesoin().getRapportTechnique() == null) {
            throw new IllegalStateException("La demande ne possède pas de rapport technique.");
        }

        RapportTechnique rapportTechnique = demande.getEtudeTerrain()
                .getRapportBesoin().getRapportTechnique();

        DetailRapportTechnique detailCorrespondant = null;

        for (DetailRapportTechnique detail : rapportTechnique.getDetails()) {
            if (detail.getDesignation() != null
                    && detail.getUnite() != null
                    && detail.getDesignation().trim().equalsIgnoreCase(designation.trim())
                    && detail.getUnite().trim().equalsIgnoreCase(unite.trim())) {

                if (detailCorrespondant != null) {
                    throw new IllegalStateException(
                            "Plusieurs détails techniques correspondent à ce matériel.");
                }

                detailCorrespondant = detail;
            }
        }

        if (detailCorrespondant == null) {
            throw new IllegalArgumentException(
                    "Le matériel sélectionné ne correspond pas aux besoins de cette demande.");
        }

        if (detailCorrespondant.getQuantite() == null
                || detailCorrespondant.getQuantite() <= 0) {
            throw new IllegalStateException(
                    "La quantité prévue dans le détail technique est invalide.");
        }

        return detailCorrespondant;
    }

    // 8. Calculer la quantité réellement reçue pour un article

    private int calculerQuantiteRecue(
            DemandeAide demande,
            String designation,
            String unite,
            Integer donAExclureId) {

        List<DonMateriel> dons = donMaterielRepository.findByDemandeAideId(demande.getId());
        int totalRecu = 0;

        for (DonMateriel don : dons) {

            if (donAExclureId != null && donAExclureId.equals(don.getId())) {
                continue;
            }

            boolean memeMateriel = don.getDesignation() != null
                    && don.getUnite() != null
                    && don.getDesignation().trim().equalsIgnoreCase(designation.trim())
                    && don.getUnite().trim().equalsIgnoreCase(unite.trim());

            boolean statutComptabilise =
                    don.getStatutReception() == StatutReception.PARTIELLEMENT_RECU
                            || don.getStatutReception() == StatutReception.RECU;

            if (memeMateriel && statutComptabilise && don.getQuantiteRecue() != null) {
                totalRecu += don.getQuantiteRecue();
            }
        }

        return totalRecu;
    }

    // 9. Calculer la valeur totale du matériel reçu pour une demande

    private double calculerValeurMaterielleRecue(DemandeAide demande) {

        RapportTechnique rapport = demande.getEtudeTerrain()
                .getRapportBesoin().getRapportTechnique();

        List<DonMateriel> dons = donMaterielRepository.findByDemandeAideId(demande.getId());
        Map<String, Integer> quantitesRecues = new HashMap<>();

        for (DonMateriel don : dons) {

            if (don.getStatutReception() != StatutReception.PARTIELLEMENT_RECU
                    && don.getStatutReception() != StatutReception.RECU) {
                continue;
            }

            int quantite = don.getQuantiteRecue() == null ? 0 : don.getQuantiteRecue();

            if (quantite <= 0) continue;

            String cle = creerCleArticle(don.getDesignation(), don.getUnite());
            quantitesRecues.merge(cle, quantite, Integer::sum);
        }

        double valeurTotale = 0.0;

        for (DetailRapportTechnique detail : rapport.getDetails()) {

            if (detail.getDesignation() == null
                    || detail.getUnite() == null
                    || detail.getQuantite() == null
                    || detail.getQuantite() <= 0
                    || detail.getPrixUnitaire() == null
                    || !Double.isFinite(detail.getPrixUnitaire())
                    || detail.getPrixUnitaire() < 0) {
                continue;
            }

            String cle = creerCleArticle(detail.getDesignation(), detail.getUnite());
            int quantiteDisponible = quantitesRecues.getOrDefault(cle, 0);
            int quantiteACompter = Math.min(quantiteDisponible, detail.getQuantite());

            valeurTotale += quantiteACompter * detail.getPrixUnitaire();

            quantitesRecues.put(cle, quantiteDisponible - quantiteACompter);
        }

        return valeurTotale;
    }

    // 10. Calculer la valeur des dons financiers réellement confirmés

    private double calculerMontantFinancierConfirme(Integer demandeAideId) {

        List<DonFinancier> dons = donFinancierRepository.findByDemandeAideId(demandeAideId);
        double total = 0.0;

        for (DonFinancier don : dons) {

            if (don.getMontant() == null
                    || !Double.isFinite(don.getMontant())
                    || don.getMontant() <= 0) {
                continue;
            }

            boolean paiementConfirme =
                    paiementDonRepository.existsByDonFinancier_IdAndStatut(
                            don.getId(), StatutPaiement.CONFIRME);

            if (paiementConfirme) {
                total += don.getMontant();
            }
        }

        return total;
    }

    // 11. Recalculer le statut de collecte après réception matérielle

    private void recalculerStatutCollecte(DemandeAide demande) {

        RapportTechnique rapport = rapportTechniqueRepository.findByDemandeAideId(demande.getId())
                .orElseThrow(() -> new IllegalStateException("Rapport technique introuvable."));

        if (rapport.getMontantFinal() == null
                || !Double.isFinite(rapport.getMontantFinal())
                || rapport.getMontantFinal() < 0) {
            throw new IllegalStateException("Le montant final du rapport technique est invalide.");
        }

        double montantFinancier = calculerMontantFinancierConfirme(demande.getId());
        double valeurMaterielle = calculerValeurMaterielleRecue(demande);
        double totalCouvert = montantFinancier + valeurMaterielle;

        if (totalCouvert <= 0) {
            demande.setStatutCollecte(StatutCollecte.NON_COMMENCEE);
        } else if (totalCouvert >= rapport.getMontantFinal()) {
            demande.setStatutCollecte(StatutCollecte.TERMINEE);
        } else {
            demande.setStatutCollecte(StatutCollecte.EN_COURS);
        }

        demandeAideRepository.save(demande);
    }

    // Clé normalisée pour reconnaître un article

    private String creerCleArticle(String designation, String unite) {
        return designation.trim().toLowerCase() + "|" + unite.trim().toLowerCase();
    }

    // 12. Calculer la valeur des dons matériels d'un donateur sur une période

    @Override
    @Transactional(readOnly = true)
    public Double calculerValeurMaterielleRecueParPeriode(
            Integer donateurId, LocalDate debut, LocalDate fin) {

        if (donateurId == null || debut == null || fin == null || debut.isAfter(fin)) {
            throw new IllegalArgumentException("Les paramètres de la période sont invalides.");
        }

        if (!estAdmin() && !getDonateurConnecte().getId().equals(donateurId)) {
            throw new AccessDeniedException("Vous ne pouvez consulter que vos propres statistiques.");
        }

        List<DonMateriel> dons =
                donMaterielRepository.findByDonateur_IdAndDateReceptionBetweenAndStatutReceptionIn(
                        donateurId,
                        debut,
                        fin,
                        List.of(StatutReception.PARTIELLEMENT_RECU, StatutReception.RECU));

        double valeurTotale = 0.0;

        for (DonMateriel don : dons) {

            if (don.getQuantiteRecue() == null
                    || don.getQuantiteRecue() <= 0
                    || don.getDemandeAide() == null) {
                continue;
            }

            DetailRapportTechnique detail = trouverDetailTechnique(
                    don.getDemandeAide(), don.getDesignation(), don.getUnite());

            if (detail.getPrixUnitaire() == null
                    || !Double.isFinite(detail.getPrixUnitaire())
                    || detail.getPrixUnitaire() < 0) {
                continue;
            }

            int quantite = Math.min(don.getQuantiteRecue(), don.getQuantite());
            valeurTotale += quantite * detail.getPrixUnitaire();
        }

        return valeurTotale;
    }

    // 13. Récupérer les dons affectables par une organisation

    @Override
    @Transactional(readOnly = true)
    public List<DonMaterielResponseDTO> getDonsAffectablesParOrganisation(Integer organisationId) {

        if (organisationId == null) {
            throw new IllegalArgumentException("L'identifiant de l'organisation est obligatoire.");
        }

        if (!estAdmin() && !getOrganisationConnectee().getId().equals(organisationId)) {
            throw new AccessDeniedException(
                    "Vous ne pouvez consulter que les dons affectables de votre organisation.");
        }

        List<DonMateriel> dons = donMaterielRepository.findDonsDirectsReceptionnes(
                organisationId,
                List.of(StatutReception.PARTIELLEMENT_RECU, StatutReception.RECU));

        return dons.stream()
                .filter(don -> {

                    Integer quantiteDejaAffectee =
                            affectationDonMaterielRepository.calculerQuantiteAffectee(don.getId());

                    if (quantiteDejaAffectee == null) {
                        quantiteDejaAffectee = 0;
                    }

                    int quantiteRecue = don.getQuantiteRecue() == null
                            ? 0 : don.getQuantiteRecue();

                    int quantiteDisponible = quantiteRecue - quantiteDejaAffectee;

                    return quantiteDisponible > 0;
                })
                .map(donMaterielMapper::toResponseDTO)
                .toList();
    }
}
