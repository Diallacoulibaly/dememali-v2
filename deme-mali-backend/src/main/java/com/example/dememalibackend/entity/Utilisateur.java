package com.example.dememalibackend.entity;

import com.example.dememalibackend.Enum.RoleEnum;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Table(name = "utilisateurs")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Inheritance(strategy = InheritanceType.JOINED)
public class Utilisateur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    @Column(nullable = false, length = 30)
    private String nom;

    @Column(nullable = false, length = 30)
    private String prenom;

    @Column(nullable = false, unique = true, length = 20)
    private String telephone;

    @Column(name = "mot_de_passe", nullable = false)
    private String motDePasse;

    private String photo;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RoleEnum role;

    @Column(name = "date_creation")
    private LocalDate dateCreation = LocalDate.now();
}