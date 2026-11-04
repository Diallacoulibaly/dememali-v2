package com.example.dememalibackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "pays")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Pays {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true)
    private String nom;

    @OneToMany(mappedBy = "pays", fetch = FetchType.LAZY)
    private List<Donateur> donateurs;
}