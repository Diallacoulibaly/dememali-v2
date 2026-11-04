package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.ArticleDemandeRequestDTO;
import com.example.dememalibackend.dto.ArticleDemandeResponseDTO;
import com.example.dememalibackend.service.ArticleDemandeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/articles-demande")
@RequiredArgsConstructor
public class ArticleDemandeController {

    private final ArticleDemandeService articleDemandeService;

    @PostMapping("/demande/{demandeId}")
    @PreAuthorize("hasAnyRole('ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<ArticleDemandeResponseDTO> ajouter(
            @PathVariable Integer demandeId,
            @RequestBody ArticleDemandeRequestDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(articleDemandeService.ajouter(demandeId, dto));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public ResponseEntity<ArticleDemandeResponseDTO> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(articleDemandeService.getById(id));
    }

    @GetMapping("/demande/{demandeId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public ResponseEntity<List<ArticleDemandeResponseDTO>> getByDemande(
            @PathVariable Integer demandeId) {
        return ResponseEntity.ok(articleDemandeService.getByDemande(demandeId));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<ArticleDemandeResponseDTO> modifier(
            @PathVariable Integer id,
            @RequestBody ArticleDemandeRequestDTO dto) {
        return ResponseEntity.ok(articleDemandeService.modifier(id, dto));
    }
}