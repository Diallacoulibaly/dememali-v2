package com.example.dememalibackend.entity;

import com.example.dememalibackend.Enum.EtatMateriel;
import com.example.dememalibackend.Enum.StatutReception;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDate;

@Entity
@Table(name = "dons_materiels")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder

@PrimaryKeyJoinColumn(name = "id")
public class DonMateriel extends Don {

    @Column(nullable = false)
    private String designation;

    @Column(nullable = false)
    private Integer quantite;

    @Column(nullable = false)
    private String unite;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EtatMateriel etatMateriel;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private StatutReception statutReception = StatutReception.EN_ATTENTE;

    private LocalDate dateReception;

    @Column(columnDefinition = "TEXT")
    private String motifRefus;
    @Builder.Default
    @Column(nullable = false)
    private Integer quantiteRecue = 0;
    @Column(name = "adresse_livraison")
    private String adresseLivraison;
}