package com.example.dememalibackend.entity;

import com.example.dememalibackend.Enum.Sexe;
import com.example.dememalibackend.Enum.SituationMatrimonial;
import com.example.dememalibackend.Enum.TypeBeneficiaireParticulier;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "beneficiaires_particuliers")
@PrimaryKeyJoinColumn(name = "id")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class BeneficiaireParticulier extends Beneficiaire {

    @Enumerated(EnumType.STRING)
    private SituationMatrimonial situationMatrimonial;

    private String typeHandicap;

    private Integer nombreEnfants;

    private LocalDate dateNaissance;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Sexe sexe;

    @Enumerated(EnumType.STRING)
    private TypeBeneficiaireParticulier typeBeneficiaireParticulier;

    @Column(columnDefinition = "TEXT")
    private String descriptionSituation;
}