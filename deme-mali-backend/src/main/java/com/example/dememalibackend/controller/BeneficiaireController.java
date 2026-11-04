package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.BeneficiaireRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireResponseDTO;
import com.example.dememalibackend.service.BeneficiaireService;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/beneficiaires")
@RequiredArgsConstructor
public class BeneficiaireController {

    private final BeneficiaireService beneficiaireService;

    // Inscription publique ou création par une organisation connectée.
    // Le contrôle des deux situations sera effectué dans le service.
    @PostMapping
    public ResponseEntity<BeneficiaireResponseDTO> creer(
            @RequestBody BeneficiaireRequestDTO dto
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(beneficiaireService.creer(dto));
    }

    // ADMIN : tous
    // ORGANISATIONPARTENAIRE : bénéficiaires de sa propre organisation
    // BENEFICIARE : ses propres informations
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    @GetMapping("/{id}")
    public ResponseEntity<BeneficiaireResponseDTO> trouverParId(
            @PathVariable Integer id
    ) {

        return ResponseEntity.ok(
                beneficiaireService.trouverParId(id)
        );
    }

    // ADMIN : tous
    // ORGANISATIONPARTENAIRE : ceux de sa propre organisation
    // BENEFICIARE : ses propres informations
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    @GetMapping
    public ResponseEntity<List<BeneficiaireResponseDTO>> trouverTous() {

        return ResponseEntity.ok(
                beneficiaireService.trouverTous()
        );
    }

    // ADMIN : tous les bénéficiaires en attente
    // ORGANISATIONPARTENAIRE : ceux de sa propre organisation
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    @GetMapping("/en-attente")
    public ResponseEntity<List<BeneficiaireResponseDTO>> trouverEnAttente() {

        return ResponseEntity.ok(
                beneficiaireService.trouverEnAttente()
        );
    }

    // ADMIN : toutes les organisations
    // ORGANISATIONPARTENAIRE : uniquement sa propre organisation
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    @GetMapping("/organisation/{organisationId}")
    public ResponseEntity<List<BeneficiaireResponseDTO>> trouverParOrganisation(
            @PathVariable Integer organisationId
    ) {

        return ResponseEntity.ok(
                beneficiaireService.trouverParOrganisation(
                        organisationId
                )
        );
    }

    // ADMIN et ORGANISATIONPARTENAIRE uniquement
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    @PutMapping("/{id}/accepter")
    public ResponseEntity<BeneficiaireResponseDTO> accepter(
            @PathVariable Integer id
    ) {

        return ResponseEntity.ok(
                beneficiaireService.accepter(id)
        );
    }

    // ADMIN et ORGANISATIONPARTENAIRE uniquement
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    @PutMapping("/{id}/refuser")
    public ResponseEntity<BeneficiaireResponseDTO> refuser(
            @PathVariable Integer id,
            @RequestParam(required = false) String motif
    ) {

        return ResponseEntity.ok(
                beneficiaireService.refuser(
                        id,
                        motif
                )
        );
    }

    // ADMIN : toutes les organisations
    // ORGANISATIONPARTENAIRE : uniquement sa propre organisation
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    @GetMapping("/acceptes/organisation/{organisationId}")
    public List<BeneficiaireResponseDTO> trouverAcceptesParOrganisation(
            @PathVariable Integer organisationId
    ) {

        return beneficiaireService.trouverAcceptesParOrganisation(
                organisationId
        );
    }
}