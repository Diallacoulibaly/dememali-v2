
package com.example.dememalibackend.entity;

import com.example.dememalibackend.Enum.StatutPaiement;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "paiements_dons")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaiementDon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "reference_transaction", unique = true)
    private String referenceTransaction;

    @Column(name = "numero_telephone", nullable = false)
    private String numeroTelephone;

    @Column(nullable = false)
    private Double montant;

    @Column(name = "date_paiement", nullable = false)
    private LocalDateTime datePaiement;

    @Column(name = "date_confirmation")
    private LocalDateTime dateConfirmation;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutPaiement statut;

    @ManyToOne(fetch = FetchType.LAZY, optional = true)
    @JoinColumn(name = "don_financier_id", nullable = true)
    private DonFinancier donFinancier;
}
