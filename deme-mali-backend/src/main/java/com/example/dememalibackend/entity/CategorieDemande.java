package com.example.dememalibackend.entity;


import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "categories_demande")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategorieDemande {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true)
    private String nom;

    @OneToMany(mappedBy = "categorieDemande", fetch = FetchType.LAZY)
    private List<DemandeAide> demandesAide;
}