package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.BeneficiaireStructureRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireStructureResponseDTO;
import com.example.dememalibackend.service.BeneficiaireStructureService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/beneficiaires/structures")
@RequiredArgsConstructor
public class BeneficiaireStructureController {

    private final BeneficiaireStructureService service;

    // Inscription publique ou création par une organisation connectée.
    // Le contrôle sera effectué dans le service.
    @PostMapping
    public ResponseEntity<BeneficiaireStructureResponseDTO> creer(
            @Valid @RequestBody
            BeneficiaireStructureRequestDTO dto
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
    public ResponseEntity<BeneficiaireStructureResponseDTO> getById(
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
    public ResponseEntity<List<BeneficiaireStructureResponseDTO>> getAll() {

        return ResponseEntity.ok(
                service.getAll()
        );
    }

    // BENEFICIARE : uniquement ses propres informations
    @PreAuthorize("hasRole('BENEFICIARE')")
    @PutMapping("/{id}")
    public ResponseEntity<BeneficiaireStructureResponseDTO> modifier(
            @PathVariable Integer id,
            @Valid @RequestBody
            BeneficiaireStructureRequestDTO dto
    ) {

        return ResponseEntity.ok(
                service.modifier(id, dto)
        );
    }
}