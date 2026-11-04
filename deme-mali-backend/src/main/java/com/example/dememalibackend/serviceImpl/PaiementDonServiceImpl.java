package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.*;
import com.example.dememalibackend.dto.PaiementDonRequestDTO;
import com.example.dememalibackend.dto.PaiementDonResponseDTO;
import com.example.dememalibackend.entity.*;
import com.example.dememalibackend.mappers.PaiementDonMapper;
import com.example.dememalibackend.repository.*;
import com.example.dememalibackend.service.PaiementDonService;

import com.example.dememalibackend.serviceImpl.CustomUserDetailsService;

import lombok.RequiredArgsConstructor;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PaiementDonServiceImpl implements PaiementDonService {

    private final DonFinancierRepository donFinancierRepository;
    private final PaiementDonRepository paiementDonRepository;
    private final DonateurRepository donateurRepository;
    private final DemandeAideRepository demandeAideRepository;
    private final RapportTechniqueRepository rapportTechniqueRepository;
    private final DetailRapportTechniqueRepository detailRapportTechniqueRepository;
    private final DonMaterielRepository donMaterielRepository;

    private final OrganisationPartenaireRepository organisationPartenaireRepository;

    private final PaiementDonMapper paiementDonMapper;

    // Vérification de l'utilisateur connecté
    private final CustomUserDetailsService customUserDetailsService;

    @Override
    @Transactional
    public PaiementDonResponseDTO effectuerPaiement(
            PaiementDonRequestDTO dto) {

        // Vérifier le donateur connecté
        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur.getRole() != RoleEnum.DONATEUR) {
            throw new AccessDeniedException(
                    "Seul un donateur peut effectuer un paiement.");
        }

        if (dto == null || dto.getDonateurId() == null
                || !utilisateur.getId().equals(dto.getDonateurId())) {
            throw new AccessDeniedException(
                    "Vous ne pouvez effectuer un paiement qu'avec votre propre compte.");
        }

        // 1. Vérifier le montant
        if (dto.getMontant() == null
                || !Double.isFinite(dto.getMontant())
                || dto.getMontant() <= 0) {
            throw new IllegalArgumentException(
                    "Le montant doit être supérieur à zéro.");
        }

        if (dto.getNumeroTelephone() == null
                || dto.getNumeroTelephone().isBlank()) {
            throw new IllegalArgumentException(
                    "Le numéro de téléphone est obligatoire.");
        }

        if (dto.getCodeSecret() == null
                || dto.getCodeSecret().isBlank()) {
            throw new IllegalArgumentException(
                    "Le code secret est obligatoire.");
        }

        if (dto.getDonateurId() == null) {
            throw new IllegalArgumentException(
                    "Le donateur est obligatoire.");
        }

        if (dto.getModePaiement() == null) {
            throw new IllegalArgumentException(
                    "Le mode de paiement est obligatoire.");
        }

        // 2. Rechercher le donateur
        Donateur donateur = donateurRepository
                .findById(dto.getDonateurId())
                .orElseThrow(() -> new IllegalArgumentException(
                        "Donateur introuvable."));

        // Vérifier qu'une seule destination est renseignée
        if (dto.getDemandeAideId() != null
                && dto.getOrganisationPartenaireId() != null) {
            throw new IllegalArgumentException(
                    "Un don ne peut pas être destiné simultanément "
                            + "à une demande d'aide et à une organisation.");
        }

        // Rechercher l'organisation si elle est renseignée
        OrganisationPartenaire organisation = null;

        if (dto.getOrganisationPartenaireId() != null) {
            organisation = organisationPartenaireRepository
                    .findById(dto.getOrganisationPartenaireId())
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Organisation partenaire introuvable."));
        }

        DemandeAide demande = null;
        RapportTechnique rapport = null;

        // 3. Vérifier la demande d'aide, si elle existe
        if (dto.getDemandeAideId() != null) {

            demande = demandeAideRepository
                    .findById(dto.getDemandeAideId())
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Demande d'aide introuvable."));

            if (demande.getStatut() != StatutDemande.VALIDEE) {
                throw new IllegalStateException(
                        "La demande d'aide doit être validée.");
            }

            if (demande.getStatutCollecte()
                    == StatutCollecte.TERMINEE) {
                throw new IllegalStateException(
                        "La collecte de cette demande est terminée.");
            }

            rapport = rapportTechniqueRepository
                    .findByDemandeAideId(demande.getId())
                    .orElseThrow(() -> new IllegalStateException(
                            "Rapport technique introuvable."));

            if (rapport.getMontantFinal() == null
                    || !Double.isFinite(rapport.getMontantFinal())
                    || rapport.getMontantFinal() <= 0) {
                throw new IllegalStateException(
                        "Le montant final du rapport technique est invalide.");
            }

            double montantRestant = calculerMontantRestant(demande);

            if (montantRestant <= 0) {
                throw new IllegalStateException(
                        "Le montant nécessaire est déjà couvert.");
            }

            if (dto.getMontant() > montantRestant) {
                throw new IllegalArgumentException(
                        "Le montant dépasse le montant restant : "
                                + montantRestant + " FCFA.");
            }
        }

        // 4. Créer le paiement
        PaiementDon paiement = new PaiementDon();

        paiement.setReferenceTransaction(
                "SIM-" + java.util.UUID.randomUUID());

        paiement.setNumeroTelephone(dto.getNumeroTelephone());
        paiement.setMontant(dto.getMontant());
        paiement.setDatePaiement(LocalDateTime.now());

        // 5. Simuler le paiement avec le code 1234
        if (!"1234".equals(dto.getCodeSecret())) {

            paiement.setStatut(StatutPaiement.ECHEC);

            PaiementDon paiementEnregistre =
                    paiementDonRepository.save(paiement);

            return paiementDonMapper.toDTO(paiementEnregistre);
        }

        // 6. Créer le don financier après la réussite du paiement
        DonFinancier don = new DonFinancier();

        don.setDateDon(LocalDate.now());
        don.setTypeDon(TypeDon.FINANCIER);
        don.setAnonyme(dto.isAnonyme());
        don.setDonateur(donateur);
        don.setDemandeAide(demande);

        // Associer l'organisation au don
        don.setOrganisationPartenaire(organisation);

        don.setMontant(dto.getMontant());
        don.setModePaiement(dto.getModePaiement());

        don = donFinancierRepository.save(don);

        // 7. Confirmer le paiement
        paiement.setDonFinancier(don);
        paiement.setStatut(StatutPaiement.CONFIRME);
        paiement.setDateConfirmation(LocalDateTime.now());

        PaiementDon paiementEnregistre =
                paiementDonRepository.save(paiement);

        // 8. Mettre à jour la collecte après confirmation
        if (demande != null) {

            double montantCollecte =
                    demande.getMontantCollecte() == null
                            ? 0.0
                            : demande.getMontantCollecte();

            double nouveauMontant =
                    montantCollecte + dto.getMontant();

            demande.setMontantCollecte(nouveauMontant);

            // Calculer la valeur du matériel déjà reçu
            double valeurMateriel =
                    calculerValeurMaterielRecu(demande.getId());

            // Comparer les dons financiers et matériels au budget
            double valeurTotale = nouveauMontant + valeurMateriel;

            if (valeurTotale >= rapport.getMontantFinal()) {
                demande.setStatutCollecte(StatutCollecte.TERMINEE);
            } else {
                demande.setStatutCollecte(StatutCollecte.EN_COURS);
            }

            demandeAideRepository.save(demande);
        }

        return paiementDonMapper.toDTO(paiementEnregistre);
    }

    // Calculer le montant restant à couvrir
    private double calculerMontantRestant(DemandeAide demande) {

        RapportTechnique rapport = rapportTechniqueRepository
                .findByDemandeAideId(demande.getId())
                .orElseThrow(() -> new IllegalStateException(
                        "Rapport technique introuvable."));

        double montantFinal = rapport.getMontantFinal();

        double montantCollecte =
                demande.getMontantCollecte() == null
                        ? 0.0
                        : demande.getMontantCollecte();

        double valeurMateriel =
                calculerValeurMaterielRecu(demande.getId());

        return Math.max(
                0.0,
                montantFinal - montantCollecte - valeurMateriel);
    }

    // Calculer la valeur du matériel réellement reçu
    private double calculerValeurMaterielRecu(Integer demandeId) {

        RapportTechnique rapport = rapportTechniqueRepository
                .findByDemandeAideId(demandeId)
                .orElseThrow(() -> new IllegalStateException(
                        "Rapport technique introuvable."));

        // Récupérer les articles du rapport technique
        List<DetailRapportTechnique> details =
                detailRapportTechniqueRepository
                        .findByRapportTechniqueId(rapport.getId());

        // Récupérer les dons matériels de la demande
        List<DonMateriel> dons =
                donMaterielRepository.findByDemandeAideId(demandeId);

        // Enregistrer les quantités réellement reçues par article
        Map<String, Integer> quantitesRecues = new HashMap<>();

        for (DonMateriel don : dons) {

            if (don.getStatutReception()
                    != StatutReception.PARTIELLEMENT_RECU
                    && don.getStatutReception()
                    != StatutReception.RECU) {
                continue;
            }

            int quantiteRecue = don.getQuantiteRecue() == null
                    ? 0
                    : don.getQuantiteRecue();

            if (quantiteRecue <= 0) {
                continue;
            }

            String cle = creerCleArticle(
                    don.getDesignation(),
                    don.getUnite());

            if (quantitesRecues.containsKey(cle)) {
                int ancienneQuantite = quantitesRecues.get(cle);
                quantitesRecues.put(
                        cle, ancienneQuantite + quantiteRecue);
            } else {
                quantitesRecues.put(cle, quantiteRecue);
            }
        }

        double valeurTotale = 0.0;

        // Comparer les dons reçus avec les articles du rapport
        for (DetailRapportTechnique detail : details) {

            if (detail.getDesignation() == null
                    || detail.getUnite() == null
                    || detail.getQuantite() == null
                    || detail.getQuantite() <= 0
                    || detail.getPrixUnitaire() == null
                    || !Double.isFinite(detail.getPrixUnitaire())
                    || detail.getPrixUnitaire() < 0) {
                continue;
            }

            String cle = creerCleArticle(
                    detail.getDesignation(),
                    detail.getUnite());

            int quantiteRecue =
                    quantitesRecues.getOrDefault(cle, 0);

            // Ne pas compter plus que la quantité prévue
            int quantiteACompter = Math.min(
                    quantiteRecue, detail.getQuantite());

            // Calculer la valeur du matériel reçu
            valeurTotale += quantiteACompter
                    * detail.getPrixUnitaire();

            // Retirer la quantité déjà comptabilisée
            quantitesRecues.put(
                    cle, quantiteRecue - quantiteACompter);
        }

        return valeurTotale;
    }

    // Créer une clé simple pour reconnaître un même article
    private String creerCleArticle(String designation, String unite) {

        String nom = designation.trim().toLowerCase();
        String mesure = unite.trim().toLowerCase();

        return nom + "|" + mesure;
    }
}