package com.example.dememalibackend.dto;


import com.example.dememalibackend.Enum.ModePaiement;
import com.example.dememalibackend.Enum.StatutDon;

import com.example.dememalibackend.Enum.TypeDon;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DonResponseDTO {

    private Integer id;
    private LocalDate dateDon;
    private TypeDon typeDon;
    private boolean anonyme;
    private StatutDon statut;
    private Integer donateurId;
    private Integer demandeAideId;
}