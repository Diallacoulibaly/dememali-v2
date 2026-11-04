package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.StatutDemande;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RapportBesoinResponseDTO {

    private Integer id;

    private String titre;

    private String besoinIdentifie;

    private String descriptionSituation;

    private String solutionProposee;

    private Double montantEstime;

    private LocalDate dateCreation;

    private Integer etudeTerrainId;

    private Integer rapportTechniqueId;
    private StatutDemande statutDemande;
}