package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.RapportBesoin;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RapportBesoinRepository
        extends JpaRepository<RapportBesoin, Integer> {

    Optional<RapportBesoin> findByEtudeTerrainId(
            Integer etudeTerrainId
    );
}