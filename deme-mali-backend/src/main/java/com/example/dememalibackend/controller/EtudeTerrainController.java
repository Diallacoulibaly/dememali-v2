
package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.EtudeTerrainRequestDTO;
import com.example.dememalibackend.dto.EtudeTerrainResponseDTO;
import com.example.dememalibackend.service.EtudeTerrainService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/etudes-terrain")
@RequiredArgsConstructor
public class EtudeTerrainController {

    private final EtudeTerrainService etudeTerrainService;

    // ORGANISATIONPARTENAIRE uniquement
    @PostMapping
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<EtudeTerrainResponseDTO> creer(
            @Valid @RequestBody EtudeTerrainRequestDTO dto) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(etudeTerrainService.creer(dto));
    }

    // Les quatre rôles
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public ResponseEntity<EtudeTerrainResponseDTO> getById(
            @PathVariable Integer id) {

        return ResponseEntity.ok(etudeTerrainService.getById(id));
    }

    // ADMIN, ORGANISATIONPARTENAIRE, BENEFICIAIRE
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<List<EtudeTerrainResponseDTO>> getAll() {

        return ResponseEntity.ok(etudeTerrainService.getAll());
    }

    // ORGANISATIONPARTENAIRE uniquement
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<EtudeTerrainResponseDTO> modifier(
            @PathVariable Integer id,
            @Valid @RequestBody EtudeTerrainRequestDTO dto) {

        return ResponseEntity.ok(etudeTerrainService.modifier(id, dto));
    }

    // ORGANISATIONPARTENAIRE uniquement
    @PutMapping("/{id}/planifier")
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<EtudeTerrainResponseDTO> planifier(
            @PathVariable Integer id,
            @Valid @RequestBody EtudeTerrainRequestDTO dto) {

        return ResponseEntity.ok(etudeTerrainService.planifier(id, dto));
    }

    // ORGANISATIONPARTENAIRE uniquement
    @PutMapping("/{id}/terminer")
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<EtudeTerrainResponseDTO> terminer(
            @PathVariable Integer id,
            @Valid @RequestBody EtudeTerrainRequestDTO dto) {

        return ResponseEntity.ok(etudeTerrainService.terminer(id, dto));
    }

    // Les quatre rôles
    @GetMapping("/demande/{demandeAideId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public ResponseEntity<EtudeTerrainResponseDTO> getByDemande(
            @PathVariable Integer demandeAideId) {

        EtudeTerrainResponseDTO etude =
                etudeTerrainService.getByDemande(demandeAideId);

        if (etude == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(etude);
    }

    // Les quatre rôles
    @GetMapping("/organisation/{organisationPartenaireId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public ResponseEntity<List<EtudeTerrainResponseDTO>> getByOrganisation(
            @PathVariable Integer organisationPartenaireId) {

        return ResponseEntity.ok(
                etudeTerrainService.getByOrganisation(organisationPartenaireId));
    }
}
