package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.StatutBeneficiaire;
import com.example.dememalibackend.Enum.TypeBeneficiaire;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class BeneficiaireResponseDTO {


    private Integer id;
    private String nom;
    private String prenom;

    private TypeBeneficiaire typeBeneficiaire;

    private String ville;

    private String adresse;

    private StatutBeneficiaire statut;

    private LocalDate dateValidation;

    private Integer organisationPartenaireId;

    private String photo;
}