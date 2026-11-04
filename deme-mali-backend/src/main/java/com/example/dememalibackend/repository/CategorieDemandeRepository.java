package com.example.dememalibackend.repository;
import com.example.dememalibackend.entity.CategorieDemande;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CategorieDemandeRepository
        extends JpaRepository<CategorieDemande, Integer> {

    Optional<CategorieDemande> findByNom(String nom);

    boolean existsByNom(String nom);
}