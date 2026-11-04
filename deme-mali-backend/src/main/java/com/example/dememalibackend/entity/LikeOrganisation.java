
package com.example.dememalibackend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "likes_organisations",
        uniqueConstraints = {@UniqueConstraint(name = "uk_like_donateur_organisation", columnNames = {"donateur_id", "organisation_id"}
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LikeOrganisation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "donateur_id", nullable = false)
    private Donateur donateur;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "organisation_id", nullable = false)
    private OrganisationPartenaire organisation;

    @Builder.Default
    @Column(nullable = false)
    private LocalDateTime dateLike = LocalDateTime.now();

    @PrePersist
    public void initialiserDateLike() {
        if (dateLike == null) {
            dateLike = LocalDateTime.now();
        }
    }
}
