package com.example.dememalibackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "affectations_dons_materiels")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AffectationDonMateriel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "quantite_affectee", nullable = false)
    private Integer quantiteAffectee;
    @Column(name = "unite", nullable = false)
    private String unite;


    @Column(name = "date_affectation", nullable = false)
    private LocalDate dateAffectation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "don_materiel_id", nullable = false)
    private DonMateriel donMateriel;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "demande_aide_id", nullable = true)
    private DemandeAide demandeAide;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "beneficiaire_id", nullable = true)
    private Beneficiaire beneficiaire;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organisation_partenaire_id", nullable = false)
    private OrganisationPartenaire organisationPartenaire;
}
