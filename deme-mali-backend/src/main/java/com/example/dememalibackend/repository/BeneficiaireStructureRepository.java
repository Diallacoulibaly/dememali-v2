package com.example.dememalibackend.repository;


import com.example.dememalibackend.entity.BeneficiaireStructure;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BeneficiaireStructureRepository
        extends JpaRepository<BeneficiaireStructure, Integer> {
}
