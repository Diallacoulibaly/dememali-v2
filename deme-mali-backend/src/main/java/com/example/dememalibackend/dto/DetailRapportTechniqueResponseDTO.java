package com.example.dememalibackend.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DetailRapportTechniqueResponseDTO {

    private Integer id;

    private String designation;

    private Integer quantite;

    private String unite;

    private Double prixUnitaire;

    private Double montant;

    private Integer rapportTechniqueId;
}