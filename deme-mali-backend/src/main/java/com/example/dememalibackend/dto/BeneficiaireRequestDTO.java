package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.Enum.TypeBeneficiaire;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class BeneficiaireRequestDTO {
    // Utilisateur
    private String nom;
    private String prenom;
    private String telephone;
    private String motDePasse;
    private RoleEnum role;

    private TypeBeneficiaire typeBeneficiaire;

    private String ville;

    private String adresse;

    private Integer organisationPartenaireId;
}