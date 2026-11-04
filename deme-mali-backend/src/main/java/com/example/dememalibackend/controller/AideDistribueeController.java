package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.AideDistribueeRequestDTO;
import com.example.dememalibackend.dto.AideDistribueeResponseDTO;
import com.example.dememalibackend.service.AideDistribueeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/aides-distribuees")
@RequiredArgsConstructor
public class AideDistribueeController {

    private final AideDistribueeService aideDistribueeService;

    // Créer une distribution : ORGANISATIONPARTENAIRE uniquement
    @PostMapping
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<AideDistribueeResponseDTO> creer(
            @Valid @RequestBody AideDistribueeRequestDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(aideDistribueeService.creer(dto));
    }

    // Récupérer toutes les distributions : ADMIN et DONATEUR
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR')")
    public ResponseEntity<List<AideDistribueeResponseDTO>> getAll() {
        return ResponseEntity.ok(aideDistribueeService.getAll());
    }

    // Récupérer une distribution par son identifiant : les 4 rôles
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<AideDistribueeResponseDTO> getById(
            @PathVariable Integer id) {
        return ResponseEntity.ok(aideDistribueeService.getById(id));
    }

    // Récupérer les distributions associées à une demande : les 4 rôles
    @GetMapping("/demande/{demandeAideId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<List<AideDistribueeResponseDTO>> getByDemande(
            @PathVariable Integer demandeAideId) {
        return ResponseEntity.ok(
                aideDistribueeService.getByDemandeAide(demandeAideId));
    }

    // Récupérer les distributions associées à un bénéficiaire : les 4 rôles
    @GetMapping("/beneficiaire/{beneficiaireId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<List<AideDistribueeResponseDTO>> getByBeneficiaire(
            @PathVariable Integer beneficiaireId) {
        return ResponseEntity.ok(
                aideDistribueeService.getByBeneficiaire(beneficiaireId));
    }

    // Récupérer les distributions terminées d'une demande : les 4 rôles
    @GetMapping("/demande/{demandeAideId}/distribuees")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<List<AideDistribueeResponseDTO>> getDistribueesByDemande(
            @PathVariable Integer demandeAideId) {
        return ResponseEntity.ok(
                aideDistribueeService.getDistribueesByDemandeAide(demandeAideId));
    }

    // Récupérer les distributions terminées d'un bénéficiaire : les 4 rôles
    @GetMapping("/beneficiaire/{beneficiaireId}/distribuees")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<List<AideDistribueeResponseDTO>> getDistribueesByBeneficiaire(
            @PathVariable Integer beneficiaireId) {
        return ResponseEntity.ok(
                aideDistribueeService.getDistribueesByBeneficiaire(beneficiaireId));
    }

    // Récupérer une distribution avec ses affectations financières
    // ADMIN, ORGANISATIONPARTENAIRE et BENEFICIAIRE
    @GetMapping("/{id}/affectations-financieres")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<AideDistribueeResponseDTO> getAvecAffectationsFinancieres(
            @PathVariable Integer id) {
        return ResponseEntity.ok(
                aideDistribueeService.getAvecAffectationsFinancieres(id));
    }

    // Récupérer une distribution avec ses affectations matérielles
    // ADMIN, ORGANISATIONPARTENAIRE et BENEFICIAIRE
    @GetMapping("/{id}/affectations-materielles")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<AideDistribueeResponseDTO> getAvecAffectationsMaterielles(
            @PathVariable Integer id) {
        return ResponseEntity.ok(
                aideDistribueeService.getAvecAffectationsMaterielles(id));
    }

    // Confirmer une distribution : ORGANISATIONPARTENAIRE uniquement
    @PatchMapping("/{id}/confirmer")
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<AideDistribueeResponseDTO> confirmer(
            @PathVariable Integer id) {
        return ResponseEntity.ok(
                aideDistribueeService.marquerCommeDistribuee(id));
    }

    // Récupérer les distributions d'une organisation
    // ADMIN, DONATEUR et ORGANISATIONPARTENAIRE
    @GetMapping("/organisation/{organisationId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<List<AideDistribueeResponseDTO>> getByOrganisation(
            @PathVariable Integer organisationId) {
        return ResponseEntity.ok(
                aideDistribueeService.getByOrganisation(organisationId));
    }
}