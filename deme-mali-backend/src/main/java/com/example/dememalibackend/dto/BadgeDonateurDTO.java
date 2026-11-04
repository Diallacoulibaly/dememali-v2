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
public class BadgeDonateurDTO {

    private Integer id;
    private String code;
    private String nom;
    private String imageUrl;
    private BigDecimal montantMinimum;
    private boolean obtenu;
    private String semestre;
    private Integer annee;
}