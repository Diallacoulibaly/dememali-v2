package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.ImageDemande;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ImageDemandeRepository
        extends JpaRepository<ImageDemande, Integer> {

    List<ImageDemande> findByDemandeAideId(Integer demandeAideId);

    boolean existsByDemandeAideId(Integer demandeAideId);
}
