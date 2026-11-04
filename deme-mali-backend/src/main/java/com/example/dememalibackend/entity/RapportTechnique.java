package com.example.dememalibackend.entity;


import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "rapports_techniques")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RapportTechnique {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(columnDefinition = "TEXT")
    private String descriptionTechnique;
    @Column(nullable = false)
    private Double montantFinal;
    private LocalDate dateCreation;

    @OneToOne(fetch = FetchType.LAZY)

    @JoinColumn(
            name = "rapport_besoin_id",
            nullable = false,
            unique = true
    )    private RapportBesoin rapportBesoin;

    @OneToMany(
            mappedBy = "rapportTechnique",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    private List<DetailRapportTechnique> details;



}