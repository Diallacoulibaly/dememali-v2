package com.example.dememalibackend.entity;

import com.example.dememalibackend.Enum.ModePaiement;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "dons_financiers")
@PrimaryKeyJoinColumn(name = "id")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DonFinancier extends Don {

    @Column(nullable = false)
    private Double montant;

    @Enumerated(EnumType.STRING)
    @Column(name = "mode_paiement", nullable = false)
    private ModePaiement modePaiement;

    @OneToMany(
            mappedBy = "donFinancier",
            cascade = CascadeType.ALL
    )
    private List<PaiementDon> paiements = new ArrayList<>();

}