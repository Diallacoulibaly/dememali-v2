package com.example.dememalibackend.entity;


import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "details_rapport_technique")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DetailRapportTechnique {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String designation;

    private Integer quantite;

    private String unite;

    private Double prixUnitaire;

    private Double montant;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rapport_technique_id", nullable = false)
    private RapportTechnique rapportTechnique;



}