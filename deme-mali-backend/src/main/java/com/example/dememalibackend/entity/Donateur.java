package com.example.dememalibackend.entity;

import com.example.dememalibackend.Enum.Sexe;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "donateurs")
@PrimaryKeyJoinColumn(name = "id")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Donateur extends Utilisateur {
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Sexe sexe;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pays_id")
    private Pays pays;

    @OneToMany(
            mappedBy = "donateur",
            fetch = FetchType.LAZY
    )
    private List<Don> dons;
    @OneToMany(
            mappedBy = "donateur",
            fetch = FetchType.LAZY
    )
    private List<LikeOrganisation> likesOrganisations;
    @OneToMany(mappedBy = "donateur")

    private List<AttributionBadge> attributionsBadges = new ArrayList<>();

}