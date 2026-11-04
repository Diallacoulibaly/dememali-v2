package com.example.dememalibackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "rapports_besoin")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RapportBesoin {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String titre;

    @Column(columnDefinition = "TEXT")
    private String besoinIdentifie;

    @Column(columnDefinition = "TEXT")
    private String descriptionSituation;

    @Column(columnDefinition = "TEXT")
    private String solutionProposee;

    private Double montantEstime;

    private LocalDate dateCreation;




    @OneToOne(
            mappedBy = "rapportBesoin",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    private RapportTechnique rapportTechnique;


    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "etude_terrain_id",
            nullable = false,
            unique = true
    )
    private EtudeTerrain etudeTerrain;

}
