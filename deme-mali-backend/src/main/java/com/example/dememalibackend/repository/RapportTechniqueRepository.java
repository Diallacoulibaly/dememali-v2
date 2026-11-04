package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.RapportTechnique;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface RapportTechniqueRepository
        extends JpaRepository<RapportTechnique, Integer> {

    Optional<RapportTechnique> findByRapportBesoinId(
            Integer rapportBesoinId
    );
    //demande lier au rapport technique
    @Query("""
        SELECT rt
        FROM RapportTechnique rt
        WHERE rt.rapportBesoin.etudeTerrain.demandeAide.id = :demandeAideId
    """)
    Optional<RapportTechnique> findByDemandeAideId(
            @Param("demandeAideId") Integer demandeAideId
    );

}