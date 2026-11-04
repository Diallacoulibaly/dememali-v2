
package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.DonateurRequestDTO;
import com.example.dememalibackend.dto.DonateurResponseDTO;
import com.example.dememalibackend.service.DonateurService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/donateurs")
@RequiredArgsConstructor
public class DonateurController {

    private final DonateurService donateurService;

    // Inscription publique
    @PostMapping
    public ResponseEntity<DonateurResponseDTO> creer(
            @RequestBody DonateurRequestDTO dto
    ) {
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(donateurService.creer(dto));
    }

    // ADMIN, DONATEUR (son propre profil),
    // ORGANISATIONPARTENAIRE et BENEFICIAIRE
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<DonateurResponseDTO> getById(
            @PathVariable Integer id
    ) {
        return ResponseEntity.ok(
                donateurService.getById(id)
        );
    }

    // ADMIN et ORGANISATIONPARTENAIRE uniquement
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<List<DonateurResponseDTO>> getAll() {
        return ResponseEntity.ok(
                donateurService.getAll()
        );
    }

    // ADMIN et DONATEUR (son propre profil)
    @PatchMapping("/{id}/pays/{paysId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR')")
    public ResponseEntity<DonateurResponseDTO> modifierPays(
            @PathVariable Integer id,
            @PathVariable Integer paysId
    ) {
        return ResponseEntity.ok(
                donateurService.modifierPays(id, paysId)
        );
    }

    // ADMIN, DONATEUR, ORGANISATIONPARTENAIRE et BENEFICIAIRE
    @GetMapping("/pays/{paysId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<List<DonateurResponseDTO>> getByPays(
            @PathVariable Integer paysId
    ) {
        return ResponseEntity.ok(
                donateurService.getByPays(paysId)
        );
    }
}
