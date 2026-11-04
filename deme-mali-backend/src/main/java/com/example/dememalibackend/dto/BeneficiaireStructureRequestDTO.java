package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.TypeBeneficiaire;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BeneficiaireStructureRequestDTO {

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
    private TypeBeneficiaire typeBeneficiaire = TypeBeneficiaire.STRUCTURE;

    //Structure

    private String nina;

    private String nif;

    private String email;

    private String nomStructure;

    private String documentJustificatif;
}
