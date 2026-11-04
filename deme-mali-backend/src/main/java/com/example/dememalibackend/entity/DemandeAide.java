package com.example.dememalibackend.entity;

import com.example.dememalibackend.Enum.*;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "demandes_aide")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DemandeAide {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String titre;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String descriptionSituation;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TypeUrgence niveauUrgence;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutDemande statut;

    @Column(nullable = false)
    private LocalDate dateCreation;

    private String motif;

    private Integer nombrePersonne;

    private Double montantNecessaire;

    private LocalDate dateValidation;

    @Enumerated(EnumType.STRING)
    private StatutCollecte statutCollecte = StatutCollecte.NON_COMMENCEE;

    private Double montantCollecte = 0.0;


    // Bénéficiaire concerné par la demande
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "beneficiaire_id", nullable = false)
    private Beneficiaire beneficiaire;

    //Organisation partenaire responsable du traitement de la demande

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organisation_partenaire_id", nullable = false)
    private OrganisationPartenaire organisationPartenaire;

    //Catégorie de la demande

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "categorie_demande_id", nullable = false)
    private CategorieDemande categorieDemande;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TypeDemande typeDemande;
    @OneToMany(mappedBy = "demandeAide", fetch = FetchType.LAZY)
    private List<Justificatif> justificatifs;

    @OneToMany(mappedBy = "demandeAide", fetch = FetchType.LAZY)
    private List<ImageDemande> images;
    @OneToMany(
            mappedBy = "demandeAide",
            fetch = FetchType.LAZY
    )
    private List<Don> dons;
    @OneToMany(
            mappedBy = "demandeAide",
            cascade = CascadeType.ALL
    )
    private List<AideDistribuee> aidesDistribuees ;
    @OneToMany(
            mappedBy = "demandeAide",
            fetch = FetchType.LAZY
    )
    private List<AffectationDon> affectationsDons;

    @Builder.Default
    @OneToMany(
            mappedBy = "demandeAide",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    private List<ArticleDemande> articles = new java.util.ArrayList<>();
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TypeDemandeAide typeDemandeAide;
    // Une demande peut avoir zéro ou une seule étude de terrain
    @OneToOne(
            mappedBy = "demandeAide",
            fetch = FetchType.LAZY
    )
    private EtudeTerrain etudeTerrain;
}