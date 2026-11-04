package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.Enum.StatutPaiement;
import com.example.dememalibackend.dto.DashboardResponseDTO;
import com.example.dememalibackend.entity.Admin;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.repository.BeneficiaireRepository;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.repository.DonFinancierRepository;
import com.example.dememalibackend.repository.DonRepository;
import com.example.dememalibackend.repository.OrganisationPartenaireRepository;
import com.example.dememalibackend.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardServiceImpl implements DashboardService {

    private final OrganisationPartenaireRepository organisationRepository;
    private final BeneficiaireRepository beneficiaireRepository;
    private final DemandeAideRepository demandeAideRepository;
    private final DonFinancierRepository donFinancierRepository;
    private final DonRepository donRepository;
    private final CustomUserDetailsService customUserDetailsService;

    @Override
    public DashboardResponseDTO getAdminDashboardStats() {

        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (!(utilisateur instanceof Admin)) {
            throw new AccessDeniedException(
                    "Vous n'avez pas l'autorisation de consulter le tableau de bord administrateur."
            );
        }

        Double totalCollecte = donFinancierRepository.calculerTotalDons(StatutPaiement.CONFIRME);

        if (totalCollecte == null || totalCollecte == 0.0) {
            totalCollecte = demandeAideRepository.calculerTotalMontantCollecte();
        }

        if (totalCollecte == null) {
            totalCollecte = 0.0;
        }

        return DashboardResponseDTO.builder()
                .totalOrganisations(organisationRepository.count())
                .totalBeneficiaires(beneficiaireRepository.count())
                .totalDemandesAide(demandeAideRepository.count())
                .totalDons(donRepository.count())
                .montantTotalCollecte(totalCollecte)
                .demandesEnAttente(demandeAideRepository.countByStatut(StatutDemande.EN_ATTENTE))
                .demandesValidees(demandeAideRepository.countByStatut(StatutDemande.VALIDEE))
                .demandesRefusees(demandeAideRepository.countByStatut(StatutDemande.REJETEE))
                .build();
    }

    @Override
    public DashboardResponseDTO getOrganisationDashboardStats(Integer organisationId) {

        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur instanceof Admin) {
            // L'administrateur peut consulter les statistiques de toutes les organisations.
        } else if (utilisateur instanceof OrganisationPartenaire organisationConnectee) {

            if (!organisationConnectee.getId().equals(organisationId)) {
                throw new AccessDeniedException(
                        "Vous ne pouvez consulter que les statistiques de votre propre organisation."
                );
            }

        } else {
            throw new AccessDeniedException(
                    "Vous n'avez pas l'autorisation de consulter ces statistiques."
            );
        }

        Double totalCollecteOrg = donFinancierRepository.calculerTotalDonsOrganisation(
                organisationId, StatutPaiement.CONFIRME
        );

        if (totalCollecteOrg == null || totalCollecteOrg == 0.0) {
            totalCollecteOrg = demandeAideRepository.calculerTotalMontantCollecteOrganisation(organisationId);
        }

        if (totalCollecteOrg == null) {
            totalCollecteOrg = 0.0;
        }

        long totalDonsOrg = donRepository.countByDemandeAideOrganisationPartenaireId(organisationId);

        return DashboardResponseDTO.builder()
                .totalOrganisations(1)
                .totalBeneficiaires(beneficiaireRepository.countByOrganisationPartenaireId(organisationId))
                .totalDemandesAide(demandeAideRepository.countByOrganisationPartenaireId(organisationId))
                .totalDons(totalDonsOrg)
                .montantTotalCollecte(totalCollecteOrg)
                .demandesEnAttente(demandeAideRepository.countByOrganisationPartenaireIdAndStatut(
                        organisationId, StatutDemande.EN_ATTENTE))
                .demandesValidees(demandeAideRepository.countByOrganisationPartenaireIdAndStatut(
                        organisationId, StatutDemande.VALIDEE))
                .demandesRefusees(demandeAideRepository.countByOrganisationPartenaireIdAndStatut(
                        organisationId, StatutDemande.REJETEE))
                .build();
    }
}