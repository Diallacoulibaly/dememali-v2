
package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.PreuveDistribution;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PreuveDistributionRepository
        extends JpaRepository<PreuveDistribution, Integer> {

    // Trouver toutes les preuves d'une distribution
    List<PreuveDistribution> findByAideDistribueeId(Integer aideDistribueeId);

    // Compter les preuves d'une distribution
    int countByAideDistribueeId(Integer aideDistribueeId);

    // Supprimer les preuves d'une distribution
    void deleteByAideDistribueeId(Integer aideDistribueeId);
}
