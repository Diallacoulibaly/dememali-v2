package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.AffectationDonMaterielRequestDTO;
import com.example.dememalibackend.dto.AffectationDonMaterielResponseDTO;
import com.example.dememalibackend.entity.AffectationDonMateriel;
import com.example.dememalibackend.mappers.AffectationDonMaterielMapper;
import com.example.dememalibackend.service.AffectationDonMaterielService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;

import java.util.List;

@RestController
@RequestMapping("/api/affectations-dons-materiels")
public class AffectationDonMaterielController {

    private final AffectationDonMaterielService service;
    private final AffectationDonMaterielMapper mapper;

    public AffectationDonMaterielController(
            AffectationDonMaterielService service,
            AffectationDonMaterielMapper mapper) {
        this.service = service;
        this.mapper = mapper;
    }

    // Créer une affectation : ORGANISATIONPARTENAIRE uniquement
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    @PostMapping
    public ResponseEntity<AffectationDonMaterielResponseDTO> affecter(
            @Valid @RequestBody AffectationDonMaterielRequestDTO dto) {

        AffectationDonMateriel affectation = service.affecter(dto);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(mapper.toDTO(affectation));
    }

    // Consulter toutes les affectations : ADMIN et ORGANISATIONPARTENAIRE
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    @GetMapping
    public ResponseEntity<List<AffectationDonMaterielResponseDTO>> getAll() {

        List<AffectationDonMaterielResponseDTO> result =
                service.getAll()
                        .stream()
                        .map(mapper::toDTO)
                        .toList();

        return ResponseEntity.ok(result);
    }

    // Consulter les affectations d'un don matériel :
    // ADMIN, ORGANISATIONPARTENAIRE et DONATEUR
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR')")
    @GetMapping("/don/{donMaterielId}")
    public ResponseEntity<List<AffectationDonMaterielResponseDTO>>
    getByDonMateriel(@PathVariable Integer donMaterielId) {

        List<AffectationDonMaterielResponseDTO> result =
                service.getByDonMateriel(donMaterielId)
                        .stream()
                        .map(mapper::toDTO)
                        .toList();

        return ResponseEntity.ok(result);
    }

    // Consulter les affectations d'un bénéficiaire :
    // ADMIN, ORGANISATIONPARTENAIRE et BENEFICIARE
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    @GetMapping("/beneficiaire/{beneficiaireId}")
    public ResponseEntity<List<AffectationDonMaterielResponseDTO>>
    getByBeneficiaire(@PathVariable Integer beneficiaireId) {

        List<AffectationDonMaterielResponseDTO> result =
                service.getByBeneficiaire(beneficiaireId)
                        .stream()
                        .map(mapper::toDTO)
                        .toList();

        return ResponseEntity.ok(result);
    }
// les affectaion materiel de l'organisation connecte
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    @GetMapping("/mes-affectations")
    public ResponseEntity<List<AffectationDonMaterielResponseDTO>> getMesAffectations() {

        List<AffectationDonMaterielResponseDTO> result =
                service.getMesAffectations()
                        .stream()
                        .map(mapper::toDTO)
                        .toList();

        return ResponseEntity.ok(result);
    }
}