
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutCollecte;
import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.Enum.StatutPaiement;
import com.example.dememalibackend.dto.ComptabiliteDonsResponseDTO;
import com.example.dememalibackend.dto.DonFinancierRequestDTO;
import com.example.dememalibackend.dto.DonFinancierResponseDTO;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.DonFinancier;
import com.example.dememalibackend.entity.RapportTechnique;
import com.example.dememalibackend.exceptions.BadRequestException;
import com.example.dememalibackend.exceptions.ResourceNotFoundException;
import com.example.dememalibackend.mappers.DonFinancierMapper;
import com.example.dememalibackend.repository.AffectationDonRepository;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.repository.DonFinancierRepository;
import com.example.dememalibackend.repository.RapportTechniqueRepository;
import com.example.dememalibackend.service.DonFinancierService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DonFinancierServiceImpl implements DonFinancierService {

    private final DonFinancierRepository donFinancierRepository;
    private final DonFinancierMapper donFinancierMapper;
    private final DemandeAideRepository demandeAideRepository;
    private final RapportTechniqueRepository rapportTechniqueRepository;
    private  final AffectationDonRepository affectationDonRepository;

    /*
     * La création d'un don financier passe toujours par le service
     * de paiement.
     */
    @Override
    @Transactional
    public DonFinancierResponseDTO creer(DonFinancierRequestDTO dto) {
        throw new BadRequestException(
                "Pour créer un don financier, veuillez effectuer "
                        + "le paiement via le service de paiement.");
    }

    @Override
    public DonFinancierResponseDTO getById(Integer id) {
        DonFinancier don = donFinancierRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Don financier introuvable."));

        return donFinancierMapper.toResponseDTO(don);
    }

    @Override
    public List<DonFinancierResponseDTO> getAll() {
        return donFinancierRepository.findAll()
                .stream()
                .map(donFinancierMapper::toResponseDTO)
                .toList();
    }

    @Override
    public List<DonFinancierResponseDTO> getByDonateur(Integer donateurId) {
        return donFinancierRepository.findByDonateurId(donateurId)
                .stream()
                .map(donFinancierMapper::toResponseDTO)
                .toList();
    }

    @Override
    public List<DonFinancierResponseDTO> getByDemande(Integer demandeAideId) {
        if (demandeAideId == null) {
            throw new BadRequestException(
                    "L'identifiant de la demande est obligatoire.");
        }

        return donFinancierRepository.findByDemandeAideId(demandeAideId)
                .stream()
                .map(donFinancierMapper::toResponseDTO)
                .toList();
    }

    @Override
    public Double getTotalDons() {
        return donFinancierRepository.calculerTotalDons(
                StatutPaiement.CONFIRME);
    }

    @Override
    public Double getTotalDonsAffectes() {
        return donFinancierRepository.calculerTotalDonsAffectes(
                StatutPaiement.CONFIRME);
    }

    @Override
    public Double getTotalDonsGeneraux() {
        return donFinancierRepository.calculerTotalDonsGeneraux(
                StatutPaiement.CONFIRME);
    }

    /*
     * Total des dons destinés directement à une organisation.
     * Seuls les paiements confirmés sont comptabilisés.
     */
    @Override
    public Double getTotalDonsOrganisation(Integer organisationId) {
        if (organisationId == null) {
            throw new BadRequestException(
                    "L'identifiant de l'organisation est obligatoire.");
        }

        return donFinancierRepository.calculerTotalDonsOrganisation(
                organisationId,
                StatutPaiement.CONFIRME);
    }

    /*
     * Comptabilité de l'organisation.
     * Les totaux généraux restent globaux, comme dans la logique existante.
     */
    @Override
    public ComptabiliteDonsResponseDTO getComptabiliteOrganisation(
            Integer organisationId) {

        if (organisationId == null) {
            throw new BadRequestException(
                    "L'identifiant de l'organisation est obligatoire.");
        }

        return ComptabiliteDonsResponseDTO.builder()
                .totalDons(getTotalDons())
                .totalDonsAffectes(getTotalDonsAffectes())
                .totalDonsGeneraux(getTotalDonsGeneraux())
                .totalDonsOrganisation(
                        getTotalDonsOrganisation(organisationId))
                .build();
    }

    /*
     * Liste des dons financiers destinés à une organisation.
     */
    @Override
    public List<DonFinancierResponseDTO> getDonsOrganisation(
            Integer organisationId) {

        if (organisationId == null) {
            throw new BadRequestException(
                    "L'identifiant de l'organisation est obligatoire.");
        }

        return donFinancierRepository.findByOrganisationId(organisationId)
                .stream()
                .map(donFinancierMapper::toResponseDTO)
                .toList();
    }

    /*
     * Don général : demandeAideId == null.
     * Don affecté : demandeAideId renseigné.
     *
     * Un don général peut également être destiné directement
     * à une organisation : aucune vérification de rapport technique
     * n'est alors nécessaire.
     */
    @Override
    public boolean verifierMontant(Integer demandeAideId, Double montant) {

        if (montant == null
                || !Double.isFinite(montant)
                || montant <= 0) {
            throw new BadRequestException(
                    "Le montant doit être supérieur à zéro.");
        }

        // Sans demande d'aide, aucun rapport technique à vérifier.
        if (demandeAideId == null) {
            return true;
        }

        DemandeAide demande = demandeAideRepository.findById(demandeAideId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Demande d'aide introuvable."));

        if (demande.getStatut() != StatutDemande.VALIDEE) {
            throw new BadRequestException(
                    "La demande d'aide n'est pas validée.");
        }

        if (demande.getStatutCollecte() == StatutCollecte.TERMINEE) {
            throw new BadRequestException(
                    "La collecte est terminée.");
        }

        RapportTechnique rapport =
                rapportTechniqueRepository.findByDemandeAideId(demandeAideId)
                        .orElseThrow(() -> new ResourceNotFoundException(
                                "Rapport technique introuvable."));

        Double montantFinal = rapport.getMontantFinal();
        Double montantCollecte = demande.getMontantCollecte();

        if (montantFinal == null
                || montantCollecte == null
                || !Double.isFinite(montantFinal)
                || !Double.isFinite(montantCollecte)
                || montantFinal <= 0
                || montantCollecte < 0) {
            throw new BadRequestException(
                    "Les montants de la demande sont invalides.");
        }

        double restant = montantFinal - montantCollecte;

        if (restant <= 0 || montant > restant) {
            throw new BadRequestException(
                    "Montant refusé. Il reste "
                            + Math.max(0, restant)
                            + " FCFA à collecter.");
        }

        return true;
    }
    @Override
    @Transactional(readOnly = true)
    public List<DonFinancierResponseDTO> getDonsAffectablesParOrganisation(
            Integer organisationId) {

        if (organisationId == null) {
            throw new IllegalArgumentException(
                    "L'identifiant de l'organisation est obligatoire.");
        }

        List<DonFinancier> dons =
                donFinancierRepository.findDonsDirectsConfirmes(
                        organisationId,
                        StatutPaiement.CONFIRME
                );

        return dons.stream()
                .filter(don -> {

                    Double montantDejaAffecte =
                            affectationDonRepository.calculerMontantAffecte(
                                    don.getId()
                            );

                    if (montantDejaAffecte == null) {
                        montantDejaAffecte = 0.0;
                    }

                    double montantDisponible =
                            don.getMontant() - montantDejaAffecte;

                    return montantDisponible > 0;
                })
                .map(donFinancierMapper::toResponseDTO)
                .toList();
    }
}
