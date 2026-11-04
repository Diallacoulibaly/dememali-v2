package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.StatutDemande;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RapportTechniqueResponseDTO {

    private Integer id;

    private String descriptionTechnique;

    private LocalDate dateCreation;

    private Integer rapportBesoinId;
    private Double montantFinal;
    private StatutDemande statutDemande;

    private List<DetailRapportTechniqueResponseDTO> details;
}