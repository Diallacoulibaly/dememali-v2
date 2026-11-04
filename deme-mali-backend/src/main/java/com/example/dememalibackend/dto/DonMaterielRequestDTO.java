package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.EtatMateriel;
import jakarta.persistence.Column;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DonMaterielRequestDTO {

    private String designation;

    private Integer quantite;
    private Integer quantiteReçue;

    private String unite;


    private Integer demandeAideId;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EtatMateriel etatMateriel;
    private boolean anonyme;
    private Integer donateurId;
    private String adresseLivraison;
    private Integer organisationPartenaireId;
}