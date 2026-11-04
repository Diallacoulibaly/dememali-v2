
package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.AideDistribuee;
import com.example.dememalibackend.Enum.StatutDistribution;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AideDistribueeRepository
        extends JpaRepository<AideDistribuee, Integer> {

    // Distributions liées à une demande
    List<AideDistribuee> findByDemandeAideId(Integer demandeAideId);

    // Distributions liées à un bénéficiaire
    List<AideDistribuee> findByBeneficiaireId(Integer beneficiaireId);

    // Distributions réalisées pour une demande
    List<AideDistribuee> findByDemandeAideIdAndStatut(
            Integer demandeAideId,
            StatutDistribution statut
    );

    // Distributions réalisées pour un bénéficiaire
    List<AideDistribuee> findByBeneficiaireIdAndStatut(
            Integer beneficiaireId,
            StatutDistribution statut
    );

    // Charger une distribution avec sa demande et son bénéficiaire
    @Query("""
        SELECT DISTINCT ad
        FROM AideDistribuee ad
        LEFT JOIN FETCH ad.demandeAide
        LEFT JOIN FETCH ad.beneficiaire
        WHERE ad.id = :distributionId
    """)
    AideDistribuee findDistributionAvecAffectationsFinancieres(
            @Param("distributionId") Integer distributionId
    );

    // Même chargement pour la consultation des affectations matérielles
    @Query("""
        SELECT DISTINCT ad
        FROM AideDistribuee ad
        LEFT JOIN FETCH ad.demandeAide
        LEFT JOIN FETCH ad.beneficiaire
        WHERE ad.id = :distributionId
    """)
    AideDistribuee findDistributionAvecAffectationsMaterielles(
            @Param("distributionId") Integer distributionId
    );
    @Query("""
    SELECT DISTINCT ad
    FROM AideDistribuee ad
    LEFT JOIN ad.demandeAide d
    LEFT JOIN ad.beneficiaire b
    WHERE d.organisationPartenaire.id = :organisationId
       OR b.organisationPartenaire.id = :organisationId
    """)
    List<AideDistribuee> findByOrganisationPartenaireId(
            @Param("organisationId") Integer organisationId
    );
}
