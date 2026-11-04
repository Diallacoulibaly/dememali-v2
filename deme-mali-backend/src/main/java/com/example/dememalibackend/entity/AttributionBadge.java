package com.example.dememalibackend.entity;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(
        name = "attributions_badges",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_donateur_badge_periode", columnNames = {"donateur_id", "badge_id", "semestre", "annee"})})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttributionBadge {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "donateur_id", nullable = false)
    private Donateur donateur;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "badge_id", nullable = false)
    private Badge badge;

    @Column(nullable = false, length = 2)
    private String semestre;

    @Column(nullable = false)
    private Integer annee;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal montantAtteint;
}
