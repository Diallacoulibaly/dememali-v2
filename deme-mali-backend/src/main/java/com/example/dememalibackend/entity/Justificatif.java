package com.example.dememalibackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "justificatifs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Justificatif {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String nomFichier;

    @Column(nullable = false)
    private String cheminFichier;

    private LocalDate dateAjout;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "type_justificatif_id", nullable = false)
    private TypeJustificatif typeJustificatif;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "demande_aide_id", nullable = false)
    private DemandeAide demandeAide;
}
