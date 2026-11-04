package com.example.dememalibackend.entity;


import com.example.dememalibackend.Enum.StatutValidation;
import com.example.dememalibackend.Enum.TypeOrganisation;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "organisations_partenaires")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrganisationPartenaire extends Utilisateur{
    @Column(nullable = false)
    private String nomOrganisation;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TypeOrganisation typeOrganisation;
    @Column(unique = true)
    private String nif;


    private String adresse;

    private String ville;

    private String documentJustificatif;
    private LocalDate dateInscription;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutValidation statutValidation = StatutValidation.EN_ATTENTE;
    private LocalDate dateValidation;
    private String description;

    private String email;

    private String telephoneOrganisation;
    // Demandes d'aide créées par l'organisation

    @OneToMany(
            mappedBy = "organisationPartenaire",
            fetch = FetchType.LAZY
    )
    private List<DemandeAide> demandesAide;

    @OneToMany(mappedBy = "organisationPartenaire", fetch = FetchType.LAZY)
    private List<Beneficiaire> beneficiaires;

    //organisation aimee par le beneficiaire
    @OneToMany(
            mappedBy = "organisation",
            fetch = FetchType.LAZY
    )
    private List<LikeOrganisation> likes;

    // Dons reçus directement par l'organisation
    @OneToMany(
            mappedBy = "organisationPartenaire",
            fetch = FetchType.LAZY
    )
    private List<Don> donsRecus;
}