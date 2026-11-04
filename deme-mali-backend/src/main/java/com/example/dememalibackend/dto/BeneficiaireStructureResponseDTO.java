package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.StatutBeneficiaire;
import com.example.dememalibackend.Enum.TypeBeneficiaire;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BeneficiaireStructureResponseDTO {

    private Integer id;

    private String nom;

    private String prenom;

    private String telephone;

    private String ville;

    private String adresse;

    private TypeBeneficiaire typeBeneficiaire;

    private StatutBeneficiaire statut;

    private LocalDate dateValidation;

    private String nina;

    private String nif;

    private String email;

    private String nomStructure;

    private String documentJustificatif;

    private Integer organisationPartenaireId;

    private String photo;
}