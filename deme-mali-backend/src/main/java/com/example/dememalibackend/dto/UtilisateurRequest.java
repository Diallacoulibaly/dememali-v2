package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.RoleEnum;
import lombok.Data;

@Data
public class UtilisateurRequest {

    private String nom;
    private String prenom;
    private String telephone;
    private String motDePasse;
    private RoleEnum role;
}