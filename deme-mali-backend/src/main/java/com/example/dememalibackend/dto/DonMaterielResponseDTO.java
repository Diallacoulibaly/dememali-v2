package com.example.dememalibackend.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class DonMaterielResponseDTO {

    private Integer id;
    private String designation;
    private Integer quantite;
    private String unite;
    private String etatMateriel;
    private String statutReception;
    private Integer quantiteRecue;
    private String adresseLivraison;
    private LocalDate dateDon;
    private boolean anonyme;
    private Integer donateurId;
    private Integer demandeAideId;
    private String titreDemandeAide;
    private Integer organisationPartenaireId;
}