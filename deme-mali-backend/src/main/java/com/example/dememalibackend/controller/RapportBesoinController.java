package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.RapportBesoinRequestDTO;
import com.example.dememalibackend.dto.RapportBesoinResponseDTO;
import com.example.dememalibackend.exceptions.ResourceNotFoundException;
import com.example.dememalibackend.service.RapportBesoinService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rapports-besoin")
@RequiredArgsConstructor
public class RapportBesoinController {

    private final RapportBesoinService rapportBesoinService;

    @GetMapping("/etude-terrain/{etudeTerrainId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public ResponseEntity<RapportBesoinResponseDTO> getByEtudeTerrain(
            @PathVariable Integer etudeTerrainId) {

        try {
            return ResponseEntity.ok(
                    rapportBesoinService.getByEtudeTerrain(etudeTerrainId)
            );
        } catch (ResourceNotFoundException ex) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<RapportBesoinResponseDTO> creer(
            @Valid @RequestBody RapportBesoinRequestDTO dto) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(rapportBesoinService.creer(dto));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public ResponseEntity<RapportBesoinResponseDTO> getById(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                rapportBesoinService.getById(id)
        );
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public ResponseEntity<List<RapportBesoinResponseDTO>> getAll() {

        return ResponseEntity.ok(
                rapportBesoinService.getAll()
        );
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<RapportBesoinResponseDTO> modifier(
            @PathVariable Integer id,
            @Valid @RequestBody RapportBesoinRequestDTO dto) {

        return ResponseEntity.ok(
                rapportBesoinService.modifier(id, dto)
        );
    }

    // Suppression désactivée : aucun endpoint DELETE.
}