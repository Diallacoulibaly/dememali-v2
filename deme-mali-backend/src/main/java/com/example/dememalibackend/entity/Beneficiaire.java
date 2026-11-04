package com.example.dememalibackend.entity;

import com.example.dememalibackend.Enum.StatutBeneficiaire;
import com.example.dememalibackend.Enum.TypeBeneficiaire;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "beneficiaires")
@PrimaryKeyJoinColumn(name = "id")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Beneficiaire extends Utilisateur {

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TypeBeneficiaire typeBeneficiaire;

    private LocalDate dateValidation;

    private String ville;

    private String adresse;
    

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutBeneficiaire statut = StatutBeneficiaire.EN_ATTENTE;

    private String motifRefus;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "organisation_partenaire_id",
            nullable = false
    )
    private OrganisationPartenaire organisationPartenaire;



    @OneToMany(
            mappedBy = "beneficiaire",
            fetch = FetchType.LAZY
    )
    private List<DemandeAide> demandesAide;
    // Affectations de dons financiers
    @OneToMany(
            mappedBy = "beneficiaire",
            fetch = FetchType.LAZY
    )
    private List<AffectationDon> affectationsDons;

    // Affectations de dons matériels
    @OneToMany(
            mappedBy = "beneficiaire",
            fetch = FetchType.LAZY
    )
    private List<AffectationDonMateriel> affectationsDonsMateriels;

}