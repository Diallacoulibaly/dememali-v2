package com.example.dememalibackend.dto;


import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.Enum.StatutValidation;
import com.example.dememalibackend.Enum.TypeOrganisation;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrganisationPartenaireResponseDTO {


    // Utilisateur
    private String nom;
    private String prenom;
    private String telephone;
    private RoleEnum role=RoleEnum.ORGANISATIONPARTENAIRE;

    private Integer id;

    private String nomOrganisation;

    private TypeOrganisation typeOrganisation;

    private String nif;

    private String adresse;

    private String ville;

    private String documentJustificatif;

    private LocalDate dateInscription;

    private StatutValidation statutValidation;
    private LocalDate dateValidation;

    private String email;

    private String telephoneOrganisation;
    // Informations des likes
    private long nombreLikes;
    private boolean aimeParMoi;


    private String description;

}