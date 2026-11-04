package com.example.dememalibackend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardResponseDTO {
    private long totalOrganisations;
    private long totalBeneficiaires;
    private long totalDemandesAide;
    private long totalDons;
    private Double montantTotalCollecte;
    
    // Statistiques par statut de demande
    private long demandesEnAttente;
    private long demandesValidees;
    private long demandesRefusees;
}
