package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.CategorieDemandeRequestDTO;
import com.example.dememalibackend.dto.CategorieDemandeResponseDTO;
import com.example.dememalibackend.service.CategorieDemandeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories-demande")
@RequiredArgsConstructor
public class CategorieDemandeController {

    private final CategorieDemandeService categorieDemandeService;

    // ADMIN uniquement
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<CategorieDemandeResponseDTO> creer(
            @Valid @RequestBody CategorieDemandeRequestDTO dto) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(categorieDemandeService.creer(dto));
    }

    // Tous les utilisateurs connectés
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<CategorieDemandeResponseDTO> getById(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                categorieDemandeService.getById(id)
        );
    }

    // Tous les utilisateurs connectés
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<List<CategorieDemandeResponseDTO>> getAll() {

        return ResponseEntity.ok(
                categorieDemandeService.getAll()
        );
    }

    // ADMIN uniquement
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<CategorieDemandeResponseDTO> modifier(
            @PathVariable Integer id,
            @Valid @RequestBody CategorieDemandeRequestDTO dto) {

        return ResponseEntity.ok(
                categorieDemandeService.modifier(id, dto)
        );
    }

    // ADMIN uniquement
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> supprimer(
            @PathVariable Integer id) {

        categorieDemandeService.supprimer(id);

        return ResponseEntity.noContent().build();
    }
}