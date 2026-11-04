package com.example.dememalibackend.entity;

import com.example.dememalibackend.Enum.StatutEtudeTerrain;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "etudes_terrain")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EtudeTerrain {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private LocalDate dateRealisation;

    private LocalDate datePlanification;

    private String lieu;

    @Column(columnDefinition = "TEXT")
    private String objectif;

    @Column(columnDefinition = "TEXT")
    private String observation;

    @Column(columnDefinition = "TEXT")
    private String resultat;
    private LocalTime heure;
    @Enumerated(EnumType.STRING)
    private StatutEtudeTerrain status;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "demande_aide_id",
            nullable = false,
            unique = true
    )
    private DemandeAide demandeAide;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organisation_partenaire_id", nullable = false)
    private OrganisationPartenaire organisationPartenaire;


    @OneToOne(
            mappedBy = "etudeTerrain",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    private RapportBesoin rapportBesoin;
}
