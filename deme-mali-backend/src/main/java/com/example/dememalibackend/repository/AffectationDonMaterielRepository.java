
package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.AffectationDonMateriel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface AffectationDonMaterielRepository
        extends JpaRepository<AffectationDonMateriel, Integer> {

    // Affectations d'un don matériel
    List<AffectationDonMateriel> findByDonMaterielId(
            Integer donMaterielId
    );

    // Affectations liées à une demande d'aide
    List<AffectationDonMateriel> findByDemandeAideId(
            Integer demandeAideId
    );

    // Affectations liées à un bénéficiaire
    List<AffectationDonMateriel> findByBeneficiaireId(
            Integer beneficiaireId
    );

    // Affectations liées à une organisation partenaire
    List<AffectationDonMateriel> findByOrganisationPartenaireId(
            Integer organisationPartenaireId
    );

    // Calculer la quantité totale affectée pour un don matériel
    @Query("""
        SELECT COALESCE(SUM(a.quantiteAffectee), 0)
        FROM AffectationDonMateriel a
        WHERE a.donMateriel.id = :donMaterielId
        """)
    Integer calculerQuantiteAffectee(
            @Param("donMaterielId") Integer donMaterielId
    );

    // Rechercher les affectations liées à la demande
    // et générales ou destinées au bénéficiaire concerné
    @Query("""
        SELECT a
        FROM AffectationDonMateriel a
        WHERE a.demandeAide.id = :demandeId
          AND (
              a.beneficiaire IS NULL
              OR a.beneficiaire.id = :beneficiaireId
          )
        """)
    List<AffectationDonMateriel> findPourDistribution(
            @Param("demandeId") Integer demandeId,
            @Param("beneficiaireId") Integer beneficiaireId
    );
}
