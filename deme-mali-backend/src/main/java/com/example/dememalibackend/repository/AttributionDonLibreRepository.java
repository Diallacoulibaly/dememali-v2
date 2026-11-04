
package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.AttributionDonLibre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AttributionDonLibreRepository
        extends JpaRepository<AttributionDonLibre, Integer> {

        // Historique des attributions d'un don financier
        List<AttributionDonLibre> findByDonFinancierId(Integer donFinancierId);

        // Historique des attributions d'un don matériel
        List<AttributionDonLibre> findByDonMaterielId(Integer donMaterielId);

        // Attributions reçues par une organisation
        List<AttributionDonLibre>
        findByOrganisationPartenaireId(Integer organisationPartenaireId);

        // Total financier déjà attribué pour un don
        @Query("""
        SELECT COALESCE(SUM(a.montantAttribue), 0)
        FROM AttributionDonLibre a
        WHERE a.donFinancier.id = :donId
        """)
        Double calculerMontantAttribue(
                @Param("donId") Integer donId
        );

        // Quantité matérielle déjà attribuée pour un don
        @Query("""
        SELECT COALESCE(SUM(a.quantiteAttribuee), 0)
        FROM AttributionDonLibre a
        WHERE a.donMateriel.id = :donId
        """)
        Integer calculerQuantiteAttribuee(
                @Param("donId") Integer donId
        );
}
