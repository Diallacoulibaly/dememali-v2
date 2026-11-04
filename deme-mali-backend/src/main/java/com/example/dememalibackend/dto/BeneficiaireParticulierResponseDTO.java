package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.*;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BeneficiaireParticulierResponseDTO {

    private Integer id;

    private String nom;
    private String prenom;
    private String telephone;

    private String ville;
    private String adresse;
    private TypeBeneficiaire typeBeneficiaire;
    private StatutBeneficiaire statut;
    private LocalDate dateValidation;

    private SituationMatrimonial situationMatrimonial;
    private String typeHandicap;
    private Integer nombreEnfants;
    private LocalDate dateNaissance;
    private Sexe sexe;
    private TypeBeneficiaireParticulier typeBeneficiaireParticulier;
    private String descriptionSituation;

    private Integer organisationPartenaireId;

    private String photo;
}