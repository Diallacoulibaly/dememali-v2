
package com.example.dememalibackend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "articles_demandes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ArticleDemande {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String designation;

    @Column(nullable = false)
    private Integer quantiteDemandee;

    @Column(nullable = false)
    private String unite;

    private Double prixUnitaireEstime;
    @Column(nullable = false)
    @Builder.Default
    private Integer quantiteRecue = 0;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "demande_aide_id", nullable = false)
    private DemandeAide demandeAide;
}
