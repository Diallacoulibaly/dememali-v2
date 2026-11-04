
package com.example.dememalibackend.entity;

import com.example.dememalibackend.Enum.TypeMedia;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "preuves_distribution")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PreuveDistribution {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "aide_distribuee_id", nullable = false)
    private AideDistribuee aideDistribuee;

    @Column(nullable = false)
    private String nomFichier;

    @Column(nullable = false, length = 1000)
    private String urlFichier;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TypeMedia typeMedia;
}
