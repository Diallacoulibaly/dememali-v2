
package com.example.dememalibackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "attributions_dons_libres")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttributionDonLibre {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // Date de l'attribution
    @Column(name = "date_attribution", nullable = false)
    private LocalDate dateAttribution;

    // Montant attribué pour un don financier
    @Column(name = "montant_attribue")
    private Double montantAttribue;

    // Quantité attribuée pour un don matériel
    @Column(name = "quantite_attribuee")
    private Integer quantiteAttribuee;

    // Score de priorité calculé pour l'organisation
    @Column(name = "score_priorite", nullable = false)
    private Double scorePriorite;

    // Don financier libre (si applicable)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "don_financier_id")
    private DonFinancier donFinancier;

    // Don matériel libre (si applicable)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "don_materiel_id")
    private DonMateriel donMateriel;

    // Organisation qui reçoit le don
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "organisation_partenaire_id",
            nullable = false
    )
    private OrganisationPartenaire organisationPartenaire;

    // Administrateur qui effectue l'attribution
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "administrateur_id", nullable = false)
    private Admin administrateur;
}
