
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutPaiement;
import com.example.dememalibackend.Enum.StatutReception;
import com.example.dememalibackend.dto.BadgeDonateurDTO;
import com.example.dememalibackend.entity.*;
import com.example.dememalibackend.repository.*;
import com.example.dememalibackend.service.BadgeService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.access.AccessDeniedException;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BadgeServiceImpl implements BadgeService {

    private final BadgeRepository badgeRepository;
    private final AttributionBadgeRepository attributionBadgeRepository;
    private final DonateurRepository donateurRepository;
    private final DonFinancierRepository donFinancierRepository;
    private final DonMaterielRepository donMaterielRepository;
    private final RapportTechniqueRepository rapportTechniqueRepository;
    private final DetailRapportTechniqueRepository detailRapportTechniqueRepository;

    // Service existant pour récupérer l'utilisateur connecté
    private final CustomUserDetailsService customUserDetailsService;

    // Vérifier les droits d'accès au donateur demandé
    private void verifierAccesDonateur(Integer donateurId) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        // ADMIN : accès à tous les donateurs
        if (utilisateur instanceof Admin) {
            return;
        }

        // DONATEUR : accès uniquement à ses propres badges
        if (utilisateur instanceof Donateur) {

            if (!utilisateur.getId().equals(donateurId)) {
                throw new AccessDeniedException(
                        "Vous ne pouvez consulter que vos propres badges."
                );
            }

            return;
        }

        // ORGANISATIONPARTENAIRE et BENEFICIAIRE : aucun accès
        throw new AccessDeniedException(
                "Vous n'avez pas l'autorisation de consulter ces badges."
        );
    }

    // 1. Afficher les badges du semestre actuel
    @Override
    @Transactional
    public List<BadgeDonateurDTO> getBadgesSemestreActuel(
            Integer donateurId) {

        // Vérifier les droits d'accès
        verifierAccesDonateur(donateurId);

        LocalDate aujourdHui = LocalDate.now();

        String semestre = aujourdHui.getMonthValue() <= 6
                ? "S1"
                : "S2";

        return getBadgesSemestre(
                donateurId,
                aujourdHui.getYear(),
                semestre
        );
    }

    // 2. Calculer les badges pour un semestre précis
    @Override
    @Transactional
    public List<BadgeDonateurDTO> getBadgesSemestre(
            Integer donateurId,
            Integer annee,
            String semestre) {

        // Vérifier les droits d'accès
        verifierAccesDonateur(donateurId);

        // Vérifier les paramètres
        if (donateurId == null || annee == null) {
            throw new IllegalArgumentException(
                    "Le donateur et l'année sont obligatoires.");
        }

        if (!"S1".equals(semestre) && !"S2".equals(semestre)) {
            throw new IllegalArgumentException(
                    "Le semestre doit être S1 ou S2.");
        }

        // Vérifier que le donateur existe
        Donateur donateur = donateurRepository.findById(donateurId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Donateur introuvable."));

        // Déterminer les dates du semestre
        LocalDate debut;
        LocalDate fin;

        if ("S1".equals(semestre)) {
            debut = LocalDate.of(annee, 1, 1);
            fin = LocalDate.of(annee, 6, 30);
        } else {
            debut = LocalDate.of(annee, 7, 1);
            fin = LocalDate.of(annee, 12, 31);
        }

        // Étape 1 : calculer les dons financiers confirmés
        Double totalFinancier =
                donFinancierRepository.calculerTotalDonsConfirmesParPeriode(
                        donateurId,
                        debut,
                        fin,
                        StatutPaiement.CONFIRME
                );

        if (totalFinancier == null) {
            totalFinancier = 0.0;
        }

        BigDecimal montantFinancier =
                BigDecimal.valueOf(totalFinancier);

        // Étape 2 : calculer la valeur des dons matériels reçus
        BigDecimal montantMateriel =
                calculerValeurMaterielRecu(
                        donateurId,
                        debut,
                        fin
                );

        // Étape 3 : additionner les deux types de dons
        BigDecimal montantTotal =
                montantFinancier.add(montantMateriel);

        // Étape 4 : récupérer les badges actifs
        List<Badge> badges =
                badgeRepository.findByActifTrueOrderByMontantMinimumAsc();

        // Étape 5 : préparer la liste des badges
        List<BadgeDonateurDTO> resultats =
                new java.util.ArrayList<>();

        for (Badge badge : badges) {

            BigDecimal montantMinimum = badge.getMontantMinimum();

            // Vérifier si le montant atteint le seuil du badge
            boolean obtenu =
                    montantTotal.compareTo(montantMinimum) >= 0;

            // Enregistrer le badge s'il est obtenu
            if (obtenu) {
                enregistrerAttribution(
                        donateur,
                        badge,
                        semestre,
                        annee,
                        montantTotal
                );
            }

            // Créer le DTO sans progression ni montant restant
            BadgeDonateurDTO dto = new BadgeDonateurDTO(
                    badge.getId(),
                    badge.getCode(),
                    badge.getNom(),
                    badge.getImageUrl(),
                    montantMinimum,
                    obtenu,
                    semestre,
                    annee
            );

            resultats.add(dto);
        }

        return resultats;
    }

    // 3. Calculer la valeur du matériel reçu pendant le semestre
    private BigDecimal calculerValeurMaterielRecu(
            Integer donateurId,
            LocalDate debut,
            LocalDate fin) {

        // Récupérer les dons matériels reçus pendant la période
        List<DonMateriel> dons =
                donMaterielRepository
                        .findByDonateur_IdAndDateReceptionBetweenAndStatutReceptionIn(
                                donateurId,
                                debut,
                                fin,
                                List.of(
                                        StatutReception.RECU,
                                        StatutReception.PARTIELLEMENT_RECU
                                )
                        );

        BigDecimal total = BigDecimal.ZERO;

        // Parcourir chaque don matériel
        for (DonMateriel don : dons) {

            if (don.getQuantiteRecue() == null
                    || don.getQuantiteRecue() <= 0) {
                continue;
            }

            // Le don doit être lié à une demande d'aide
            if (don.getDemandeAide() == null) {
                continue;
            }

            // Récupérer le rapport technique de la demande
            RapportTechnique rapport =
                    rapportTechniqueRepository
                            .findByDemandeAideId(
                                    don.getDemandeAide().getId()
                            )
                            .orElseThrow(() ->
                                    new IllegalStateException(
                                            "Rapport technique introuvable."
                                    ));

            // Récupérer les articles du rapport
            List<DetailRapportTechnique> details =
                    detailRapportTechniqueRepository
                            .findByRapportTechniqueId(rapport.getId());

            // Rechercher le prix unitaire du matériel
            for (DetailRapportTechnique detail : details) {

                if (detail.getDesignation() == null
                        || detail.getUnite() == null
                        || detail.getPrixUnitaire() == null
                        || !Double.isFinite(detail.getPrixUnitaire())
                        || detail.getPrixUnitaire() < 0
                        || detail.getQuantite() == null
                        || detail.getQuantite() <= 0) {
                    continue;
                }

                boolean memeDesignation =
                        detail.getDesignation().trim()
                                .equalsIgnoreCase(
                                        don.getDesignation().trim()
                                );

                boolean memeUnite =
                        detail.getUnite().trim()
                                .equalsIgnoreCase(
                                        don.getUnite().trim()
                                );

                if (memeDesignation && memeUnite) {

                    // Ne pas dépasser la quantité prévue au rapport
                    int quantiteACompter = Math.min(
                            don.getQuantiteRecue(),
                            detail.getQuantite()
                    );

                    BigDecimal prixUnitaire =
                            BigDecimal.valueOf(
                                    detail.getPrixUnitaire()
                            );

                    BigDecimal valeur =
                            prixUnitaire.multiply(
                                    BigDecimal.valueOf(quantiteACompter)
                            );

                    total = total.add(valeur);

                    // Le matériel correspondant a été trouvé
                    break;
                }
            }
        }

        return total;
    }

    // 4. Enregistrer un badge une seule fois par semestre et par année
    private void enregistrerAttribution(
            Donateur donateur,
            Badge badge,
            String semestre,
            Integer annee,
            BigDecimal montantAtteint) {

        boolean existe =
                attributionBadgeRepository
                        .existsByDonateur_IdAndBadge_IdAndSemestreAndAnnee(
                                donateur.getId(),
                                badge.getId(),
                                semestre,
                                annee
                        );

        if (!existe) {

            AttributionBadge attribution = new AttributionBadge();

            attribution.setDonateur(donateur);
            attribution.setBadge(badge);
            attribution.setSemestre(semestre);
            attribution.setAnnee(annee);
            attribution.setMontantAtteint(montantAtteint);

            attributionBadgeRepository.save(attribution);
        }
    }

    // 5. Consulter l'historique des badges obtenus
    @Override
    @Transactional(readOnly = true)
    public List<BadgeDonateurDTO> getHistorique(
            Integer donateurId) {

        // Vérifier les droits d'accès
        verifierAccesDonateur(donateurId);

        if (donateurId == null) {
            throw new IllegalArgumentException(
                    "L'identifiant du donateur est obligatoire.");
        }

        // Récupérer les attributions précédentes du donateur
        List<AttributionBadge> attributions =
                attributionBadgeRepository
                        .findByDonateur_IdOrderByAnneeDescSemestreDesc(
                                donateurId
                        );

        List<BadgeDonateurDTO> resultats =
                new java.util.ArrayList<>();

        for (AttributionBadge attribution : attributions) {

            Badge badge = attribution.getBadge();

            BadgeDonateurDTO dto = new BadgeDonateurDTO(
                    badge.getId(),
                    badge.getCode(),
                    badge.getNom(),
                    badge.getImageUrl(),
                    badge.getMontantMinimum(),
                    true,
                    attribution.getSemestre(),
                    attribution.getAnnee()
            );

            resultats.add(dto);
        }

        return resultats;
    }
}
