package com.example.dememalibackend.dto;


import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DetailRapportTechniqueRequestDTO {

    private String designation;

    private Integer quantite;

    private String unite;

    private Double prixUnitaire;
    private Integer id;
}