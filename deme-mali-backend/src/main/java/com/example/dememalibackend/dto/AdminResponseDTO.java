package com.example.dememalibackend.dto;

import lombok.Data;

import java.time.LocalDate;

@Data
public class AdminResponseDTO {

    private String nom;
    private String prenom;
    private String telephone;
    private String role;
    private LocalDate dateCreation;
}
