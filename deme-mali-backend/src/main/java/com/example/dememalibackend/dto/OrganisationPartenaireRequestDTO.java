package com.example.dememalibackend.dto;


import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.Enum.TypeOrganisation;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrganisationPartenaireRequestDTO {
    // Utilisateur
    private String nom;
    private String prenom;
    private String telephone;
    private String motDePasse;

    //Organisation
    private String nomOrganisation;
    private TypeOrganisation typeOrganisation;
    private String nif;
    private String adresse;
    private String ville;
    private String documentJustificatif;
    private String email;
    private String telephoneOrganisation;
    private String description;

}