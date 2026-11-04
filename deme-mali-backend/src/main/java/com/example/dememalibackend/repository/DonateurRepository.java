package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.Donateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DonateurRepository
        extends JpaRepository<Donateur, Integer> {

    List<Donateur> findByPaysId(Integer paysId);
}