package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.TypeJustificatif;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TypeJustificatifRepository
        extends JpaRepository<TypeJustificatif, Integer> {

    boolean existsByNom(String nom);
}