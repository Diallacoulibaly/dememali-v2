package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.Badge;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface BadgeRepository extends JpaRepository<Badge, Integer> {

    List<Badge> findByActifTrueOrderByMontantMinimumAsc();

    Optional<Badge> findByCode(String code);

}