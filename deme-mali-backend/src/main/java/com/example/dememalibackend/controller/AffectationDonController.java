package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.AffectationDonRequestDTO;
import com.example.dememalibackend.dto.AffectationDonResponseDTO;
import com.example.dememalibackend.dto.AttributionDonLibreRequestDTO;
import com.example.dememalibackend.service.AffectationDonService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;

import java.util.List;

@RestController
@RequestMapping("/api/affectations-dons")
public class AffectationDonController {

    private final AffectationDonService affectationDonService;

    public AffectationDonController(
            AffectationDonService affectationDonService) {
        this.affectationDonService = affectationDonService;
    }

    // Créer une affectation de don financier
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    @PostMapping
    public ResponseEntity<AffectationDonResponseDTO> creer(
            @Valid @RequestBody AffectationDonRequestDTO dto,
            @RequestParam Integer organisationPartenaireId) {

        AffectationDonResponseDTO response =
                affectationDonService.creer(
                        dto,
                        organisationPartenaireId
                );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

    // Consulter une affectation par son ID
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    @GetMapping("/{id}")
    public ResponseEntity<AffectationDonResponseDTO> getById(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                affectationDonService.getById(id)
        );
    }

    // Consulter toutes les affectations
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    @GetMapping
    public ResponseEntity<List<AffectationDonResponseDTO>> getAll() {

        return ResponseEntity.ok(
                affectationDonService.getAll()
        );
    }

    // Consulter les affectations d'un don financier
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR')")
    @GetMapping("/don/{donFinancierId}")
    public ResponseEntity<List<AffectationDonResponseDTO>> getByDon(
            @PathVariable Integer donFinancierId) {

        return ResponseEntity.ok(
                affectationDonService.getByDon(donFinancierId)
        );
    }

    // Consulter les affectations d'une demande d'aide
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    @GetMapping("/demande/{demandeAideId}")
    public ResponseEntity<List<AffectationDonResponseDTO>> getByDemande(
            @PathVariable Integer demandeAideId) {

        return ResponseEntity.ok(
                affectationDonService.getByDemande(demandeAideId)
        );
    }
// les affection de l'organisation connecte
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    @GetMapping("/mes-affectations")
    public ResponseEntity<List<AffectationDonResponseDTO>> getMesAffectations() {
        return ResponseEntity.ok(affectationDonService.getMesAffectations());
    }
}
