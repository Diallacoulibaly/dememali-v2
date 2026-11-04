package com.example.dememalibackend.repository;


import com.example.dememalibackend.entity.Pays;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PaysRepository extends JpaRepository<Pays, Integer> {

    boolean existsByNom(String nom);
}