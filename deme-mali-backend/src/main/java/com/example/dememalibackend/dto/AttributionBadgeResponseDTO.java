package com.example.dememalibackend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AttributionBadgeResponseDTO {

    private Integer id;
    private Integer donateurId;
    private Integer badgeId;
    private String codeBadge;
    private String nomBadge;
    private String imageUrl;
    private String semestre;
    private Integer annee;
    private BigDecimal montantAtteint;
}