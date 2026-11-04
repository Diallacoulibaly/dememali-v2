package com.example.dememalibackend.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RapportBesoinRequestDTO {

    private String titre;

    private String besoinIdentifie;

    private String descriptionSituation;

    private String solutionProposee;

    private Double montantEstime;

    private Integer etudeTerrainId;
}