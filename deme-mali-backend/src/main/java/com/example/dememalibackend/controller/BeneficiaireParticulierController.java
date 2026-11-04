package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.BeneficiaireParticulierRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireParticulierResponseDTO;
import com.example.dememalibackend.service.BeneficiaireParticulierService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/beneficiaires/particuliers")
@RequiredArgsConstructor
public class BeneficiaireParticulierController {

    private final BeneficiaireParticulierService service;

    // Inscription publique ou création par une organisation connectée.
    // Le contrôle sera effectué dans le service.
    @PostMapping
    public ResponseEntity<BeneficiaireParticulierResponseDTO> creer(
            @Valid @RequestBody
            BeneficiaireParticulierRequestDTO dto
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(service.creer(dto));
    }

    // ADMIN : tous
    // ORGANISATIONPARTENAIRE : bénéficiaires de sa propre organisation
    // BENEFICIARE : ses propres informations
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    @GetMapping("/{id}")
    public ResponseEntity<BeneficiaireParticulierResponseDTO> getById(
            @PathVariable Integer id
    ) {

        return ResponseEntity.ok(
                service.getById(id)
        );
    }

    // ADMIN : tous
    // ORGANISATIONPARTENAIRE : ceux de sa propre organisation
    // BENEFICIARE : ses propres informations
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    @GetMapping
    public ResponseEntity<List<BeneficiaireParticulierResponseDTO>> getAll() {

        return ResponseEntity.ok(
                service.getAll()
        );
    }

    // BENEFICIARE : uniquement ses propres informations
    @PreAuthorize("hasRole('BENEFICIARE')")
    @PutMapping("/{id}")
    public ResponseEntity<BeneficiaireParticulierResponseDTO> modifier(
            @PathVariable Integer id,
            @Valid @RequestBody
            BeneficiaireParticulierRequestDTO dto
    ) {

        return ResponseEntity.ok(
                service.modifier(id, dto)
        );
    }
}