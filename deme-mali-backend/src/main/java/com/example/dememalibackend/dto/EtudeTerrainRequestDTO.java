package com.example.dememalibackend.dto;


import com.example.dememalibackend.Enum.StatutEtudeTerrain;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EtudeTerrainRequestDTO {

    private LocalDate dateRealisation;

    private LocalDate datePlanification;

    private String lieu;

    private String objectif;

    private String observation;

    private String resultat;

    private LocalTime heure;

    private StatutEtudeTerrain status;

    private Integer demandeAideId;

    private Integer organisationPartenaireId;
}
