
package com.example.dememalibackend.repository;

import com.example.dememalibackend.Enum.StatutEtudeTerrain;
import com.example.dememalibackend.entity.EtudeTerrain;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EtudeTerrainRepository
        extends JpaRepository<EtudeTerrain, Integer> {

    Optional<EtudeTerrain> findByDemandeAideId(Integer demandeAideId);

    boolean existsByDemandeAideIdAndStatus(Integer demandeAideId, StatutEtudeTerrain status);

    List<EtudeTerrain> findByOrganisationPartenaireId(
            Integer organisationPartenaireId);
}
