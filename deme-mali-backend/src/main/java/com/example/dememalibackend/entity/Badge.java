package com.example.dememalibackend.entity;



import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "badges")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Badge {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true)
    private String code;

    @Column(nullable = false)
    private String nom;

    private String imageUrl;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal montantMinimum;

    @Column(nullable = false)
    @Builder.Default
    private boolean actif = true;
}

