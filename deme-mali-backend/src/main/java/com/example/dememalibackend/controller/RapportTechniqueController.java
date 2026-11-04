
package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.RapportTechniqueRequestDTO;
import com.example.dememalibackend.dto.RapportTechniqueResponseDTO;
import com.example.dememalibackend.service.RapportTechniqueService;

import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rapports-techniques")
@RequiredArgsConstructor
public class RapportTechniqueController {

    private final RapportTechniqueService rapportTechniqueService;

    // Création : ORGANISATIONPARTENAIRE uniquement
    @PostMapping
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<RapportTechniqueResponseDTO> creer(
            @RequestBody RapportTechniqueRequestDTO dto) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(rapportTechniqueService.creer(dto));
    }

    // Consultation par ID : tous les rôles
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'BENEFICIARE', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<RapportTechniqueResponseDTO> getById(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                rapportTechniqueService.getById(id)
        );
    }

    // Consultation de tous les rapports : tous les rôles
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'BENEFICIARE', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<List<RapportTechniqueResponseDTO>> getAll() {

        return ResponseEntity.ok(
                rapportTechniqueService.getAll()
        );
    }

    // Consultation par rapport de besoin : tous les rôles
    @GetMapping("/rapport-besoin/{rapportBesoinId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'BENEFICIARE', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<RapportTechniqueResponseDTO> getByRapportBesoin(
            @PathVariable Integer rapportBesoinId) {

        return ResponseEntity.ok(
                rapportTechniqueService.getByRapportBesoin(rapportBesoinId)
        );
    }

    // Modification : ORGANISATIONPARTENAIRE uniquement
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<RapportTechniqueResponseDTO> modifier(
            @PathVariable Integer id,
            @RequestBody RapportTechniqueRequestDTO dto) {

        return ResponseEntity.ok(
                rapportTechniqueService.modifier(id, dto)
        );
    }
}
