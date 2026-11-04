
package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.AffectationDon;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface AffectationDonRepository
        extends JpaRepository<AffectationDon, Integer> {

    // Affectations d'un don financier
    List<AffectationDon> findByDonFinancierId(
            Integer donFinancierId
    );

    // Affectations liées à une demande d'aide
    List<AffectationDon> findByDemandeAideId(
            Integer demandeAideId
    );

    // Affectations liées à un bénéficiaire
    List<AffectationDon> findByBeneficiaireId(
            Integer beneficiaireId
    );

    // Affectations liées à une organisation partenaire
    List<AffectationDon> findByOrganisationPartenaireId(
            Integer organisationPartenaireId
    );

    // Calculer le montant total affecté pour un don financier
    @Query("""
        SELECT COALESCE(SUM(a.montantAffecte), 0)
        FROM AffectationDon a
        WHERE a.donFinancier.id = :donFinancierId
        """)
    Double calculerMontantAffecte(
            @Param("donFinancierId") Integer donFinancierId
    );

    // Affectations de la demande générales
    // ou destinées au bénéficiaire concerné
    @Query("""
        SELECT a
        FROM AffectationDon a
        WHERE a.demandeAide.id = :demandeId
          AND (
              a.beneficiaire IS NULL
              OR a.beneficiaire.id = :beneficiaireId
          )
        """)
    List<AffectationDon> findPourDistribution(
            @Param("demandeId") Integer demandeId,
            @Param("beneficiaireId") Integer beneficiaireId
    );
}
