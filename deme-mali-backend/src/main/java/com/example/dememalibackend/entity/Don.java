package com.example.dememalibackend.entity;

import com.example.dememalibackend.Enum.TypeDon;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "dons")
@Inheritance(strategy = InheritanceType.JOINED)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Don {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "date_don", nullable = false)
    private LocalDate dateDon;

    @Enumerated(EnumType.STRING)
    @Column(name = "type_don", nullable = false)
    private TypeDon typeDon;

    @Column(nullable = false)
    private boolean anonyme;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "donateur_id", nullable = false)
    private Donateur donateur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "demande_aide_id")
    private DemandeAide demandeAide;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organisation_partenaire_id")
    private OrganisationPartenaire organisationPartenaire;
}
