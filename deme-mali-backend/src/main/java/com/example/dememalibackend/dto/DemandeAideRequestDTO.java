package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.TypeDemande;
import com.example.dememalibackend.Enum.TypeDemandeAide;
import com.example.dememalibackend.Enum.TypeUrgence;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DemandeAideRequestDTO {

    private String titre;

    private String descriptionSituation;

    private TypeUrgence niveauUrgence;

    private String motif;

    private Integer nombrePersonne;

    private Double montantNecessaire;

    private Integer beneficiaireId;

    private Integer organisationPartenaireId;

    private Integer categorieDemandeId;

    private TypeDemande typeDemande;

    private TypeDemandeAide typeDemandeAide;

    private List<ArticleDemandeRequestDTO> articles;
}