package com.example.dememalibackend.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "types_justificatif")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TypeJustificatif {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true)
    private String nom;

    @OneToMany(mappedBy = "typeJustificatif", fetch = FetchType.LAZY)
    private List<Justificatif> justificatifs;
}
