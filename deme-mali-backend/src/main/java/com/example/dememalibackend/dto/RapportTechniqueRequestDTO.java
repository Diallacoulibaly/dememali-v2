package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.StatutDemande;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RapportTechniqueRequestDTO {

    private String descriptionTechnique;

    private Integer rapportBesoinId;
    private Double montantFinal;

    private List<DetailRapportTechniqueRequestDTO> details;
}