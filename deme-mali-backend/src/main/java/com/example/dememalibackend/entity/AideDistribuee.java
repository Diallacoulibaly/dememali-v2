
package com.example.dememalibackend.entity;

import com.example.dememalibackend.Enum.StatutDistribution;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "aides_distribuees")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AideDistribuee {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // Facultatif : distribution liée à une demande d'aide
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "demande_aide_id")
    private DemandeAide demandeAide;

    // Facultatif : distribution directe à un bénéficiaire
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "beneficiaire_id")
    private Beneficiaire beneficiaire;

    private LocalDate dateDistribution;

    private String lieuDistribution;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutDistribution statut = StatutDistribution.EN_ATTENTE;

    @OneToMany(
            mappedBy = "aideDistribuee",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<PreuveDistribution> preuves = new ArrayList<>();
}
