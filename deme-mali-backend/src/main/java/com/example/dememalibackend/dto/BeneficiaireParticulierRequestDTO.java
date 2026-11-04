package com.example.dememalibackend.dto;


import com.example.dememalibackend.Enum.Sexe;
import com.example.dememalibackend.Enum.SituationMatrimonial;
import com.example.dememalibackend.Enum.TypeBeneficiaire;
import com.example.dememalibackend.Enum.TypeBeneficiaireParticulier;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BeneficiaireParticulierRequestDTO {


    // Utilisateur
    private String nom;
    private String prenom;
    private String telephone;
    private String motDePasse;

    // Beneficiaire
    private String ville;
    private String adresse;
    private Integer organisationPartenaireId;
    @Builder.Default
    private TypeBeneficiaire typeBeneficiaire = TypeBeneficiaire.PARTICULIER;


    //Particulier

    private SituationMatrimonial situationMatrimonial;

    private String typeHandicap;

    private Integer nombreEnfants;

    private LocalDate dateNaissance;

    private Sexe sexe;

    private TypeBeneficiaireParticulier typeBeneficiaireParticulier;

    private String descriptionSituation;
}
