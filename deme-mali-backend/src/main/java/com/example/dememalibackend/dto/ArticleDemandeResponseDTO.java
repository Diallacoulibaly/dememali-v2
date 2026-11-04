package com.example.dememalibackend.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ArticleDemandeResponseDTO {

    private Integer id;

    private String designation;

    private Integer quantiteDemandee;

    private String unite;

    private Double prixUnitaireEstime;
}