package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.Don;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DonRepository extends JpaRepository<Don, Integer> {

    List<Don> findByDonateurId(Integer donateurId);

    List<Don> findByDemandeAideId(Integer demandeAideId);

    @Query("""
        SELECT COUNT(DISTINCT d.donateur.id)
        FROM Don d
        WHERE d.demandeAide.id = :demandeId
    """)
    Long compterDonateursDistinctsParDemande(
            @Param("demandeId") Integer demandeId
    );
    long countByDemandeAideOrganisationPartenaireId(Integer organisationId);
}