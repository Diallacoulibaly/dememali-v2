package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.DonRequestDTO;
import com.example.dememalibackend.dto.DonResponseDTO;
import com.example.dememalibackend.service.DonService;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/dons")
@RequiredArgsConstructor
public class DonController {

    private final DonService donService;

    // Créer un don : DONATEUR uniquement
    @PostMapping
    @PreAuthorize("hasRole('DONATEUR')")
    public ResponseEntity<DonResponseDTO> creer(
            @RequestBody DonRequestDTO dto
    ) {
        return ResponseEntity.ok(
                donService.creer(dto)
        );
    }

    // Consulter un don par son ID : les quatre rôles
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<DonResponseDTO> getById(
            @PathVariable Integer id
    ) {
        return ResponseEntity.ok(
                donService.getById(id)
        );
    }

    // Consulter tous les dons : les quatre rôles
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<List<DonResponseDTO>> getAll() {

        return ResponseEntity.ok(
                donService.getAll()
        );
    }

    // Consulter les dons d'un donateur : ADMIN et DONATEUR
    @GetMapping("/donateur/{donateurId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR')")
    public ResponseEntity<List<DonResponseDTO>> getByDonateur(
            @PathVariable Integer donateurId
    ) {
        return ResponseEntity.ok(
                donService.getByDonateur(donateurId)
        );
    }

    // Consulter les dons d'une demande : les quatre rôles
    @GetMapping("/demande/{demandeAideId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<List<DonResponseDTO>> getByDemande(
            @PathVariable Integer demandeAideId
    ) {
        return ResponseEntity.ok(
                donService.getByDemande(demandeAideId)
        );
    }
}