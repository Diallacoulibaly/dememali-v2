package com.example.dememalibackend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "beneficiaires_structures")
@PrimaryKeyJoinColumn(name = "id")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class BeneficiaireStructure extends Beneficiaire {

    private String nina;

    private String nif;

    private String email;

    private String nomStructure;

    private String documentJustificatif;
}