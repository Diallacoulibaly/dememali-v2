package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.AttributionDonLibreRequestDTO;
import com.example.dememalibackend.dto.AttributionDonLibreResponseDTO;
import com.example.dememalibackend.dto.OrganisationPrioritaireResponseDTO;
import com.example.dememalibackend.service.AttributionDonLibreService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/attributions-dons-libres")
@RequiredArgsConstructor
public class AttributionDonLibreController {

    private final AttributionDonLibreService attributionService;

    // Attribuer un don libre : ADMIN uniquement
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AttributionDonLibreResponseDTO> attribuer(
            @Valid @RequestBody AttributionDonLibreRequestDTO dto,
            @RequestParam Integer administrateurId) {

        AttributionDonLibreResponseDTO response =
                attributionService.attribuer(dto, administrateurId);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

    // Consulter une attribution par son ID : ADMIN et ORGANISATIONPARTENAIRE
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<AttributionDonLibreResponseDTO> getById(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                attributionService.getById(id)
        );
    }

    // Consulter toutes les attributions :
    // ADMIN : toutes les attributions
    // ORGANISATIONPARTENAIRE : uniquement les siennes
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<List<AttributionDonLibreResponseDTO>> getAll() {

        return ResponseEntity.ok(
                attributionService.getAll()
        );
    }

    // Consulter les attributions d'une organisation
    // ADMIN : toutes les organisations
    // ORGANISATIONPARTENAIRE : uniquement sa propre organisation
    @GetMapping("/organisation/{organisationPartenaireId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<List<AttributionDonLibreResponseDTO>> getByOrganisation(
            @PathVariable Integer organisationPartenaireId) {

        return ResponseEntity.ok(
                attributionService.getByOrganisation(
                        organisationPartenaireId
                )
        );
    }

    // Trouver l'organisation prioritaire : ADMIN uniquement
    @GetMapping("/organisation-prioritaire")
    @PreAuthorize("hasRole('ADMIN')")
    public OrganisationPrioritaireResponseDTO trouverOrganisationPrioritaire(
            @RequestParam(required = false) Integer donFinancierId,
            @RequestParam(required = false) Integer donMaterielId) {

        return attributionService.trouverOrganisationPrioritaire(
                donFinancierId,
                donMaterielId
        );
    }
}