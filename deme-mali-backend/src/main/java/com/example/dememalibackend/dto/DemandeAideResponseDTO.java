package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.*;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DemandeAideResponseDTO {

    private Integer id;

    private String titre;

    private String descriptionSituation;

    private TypeUrgence niveauUrgence;

    private StatutDemande statut;

    private LocalDate dateCreation;

    private String motif;

    private Integer nombrePersonne;

    private Double montantNecessaire;

    private LocalDate dateValidation;

    private StatutCollecte statutCollecte;

    private Double montantCollecte;

    private Integer beneficiaireId;

    private String beneficiaireNom;

    private String beneficiairePrenom;

    private Integer organisationPartenaireId;

    private Integer categorieDemandeId;

    private String categorieDemandeNom;

    private TypeDemande typeDemande;
    private TypeDemandeAide typeDemandeAide;
    private List<ArticleDemandeResponseDTO> articles;
    private Long nombreDonateurs;
}