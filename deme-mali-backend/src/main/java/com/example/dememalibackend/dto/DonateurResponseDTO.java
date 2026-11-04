package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.Sexe;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DonateurResponseDTO {

    private Integer id;
    private String nom;
    private String prenom;
    private String telephone;
    private Sexe sexe;
    private Integer paysId;
    private String paysNom;
    private String photo;
}