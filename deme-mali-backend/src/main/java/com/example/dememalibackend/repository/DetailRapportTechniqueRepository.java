package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.DetailRapportTechnique;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DetailRapportTechniqueRepository
        extends JpaRepository<DetailRapportTechnique, Integer> {

    List<DetailRapportTechnique> findByRapportTechniqueId(
            Integer rapportTechniqueId
    );
}
