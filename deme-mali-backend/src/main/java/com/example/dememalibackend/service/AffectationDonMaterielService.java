package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.AffectationDonMaterielRequestDTO;
import com.example.dememalibackend.entity.AffectationDonMateriel;

import java.util.List;

public interface AffectationDonMaterielService {

    AffectationDonMateriel affecter(
            AffectationDonMaterielRequestDTO dto);

    List<AffectationDonMateriel> getAll();

    List<AffectationDonMateriel> getByDonMateriel(
            Integer donMaterielId);

    List<AffectationDonMateriel> getByBeneficiaire(
            Integer beneficiaireId);

    // Consulter les affectations de l'organisation connectée
    List<AffectationDonMateriel> getMesAffectations();
}