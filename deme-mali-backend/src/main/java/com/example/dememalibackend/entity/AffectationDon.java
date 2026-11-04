
        package com.example.dememalibackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "affectations_dons")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AffectationDon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "montant_affecte", nullable = false)
    private Double montantAffecte;

    @Column(name = "date_affectation", nullable = false)
    private LocalDate dateAffectation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "don_financier_id", nullable = false)
    private DonFinancier donFinancier;

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
