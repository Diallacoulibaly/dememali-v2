package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.Sexe;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DonateurRequestDTO {

    private String nom;
    private String prenom;
    private String telephone;
    private String motDePasse;
    private Sexe sexe;
    private Integer paysId;
}