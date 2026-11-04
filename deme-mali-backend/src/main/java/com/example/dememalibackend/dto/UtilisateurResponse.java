package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.Enum.TypeOrganisation;
import lombok.Data;

@Data
public class UtilisateurResponse {
    private Integer id;

    private String nom;
    private String prenom;
    private String telephone;
    private RoleEnum role;
    private TypeOrganisation typeOrganisation;
}
