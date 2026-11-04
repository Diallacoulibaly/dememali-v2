
package com.example.dememalibackend.controller;

import com.example.dememalibackend.Enum.TypeMedia;
import com.example.dememalibackend.dto.PreuveDistributionRequestDTO;
import com.example.dememalibackend.dto.PreuveDistributionResponseDTO;
import com.example.dememalibackend.service.PreuveDistributionService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/preuves-distribution")
@RequiredArgsConstructor
public class PreuveDistributionController {

    private final PreuveDistributionService preuveDistributionService;

    // Ajouter une preuve à une distribution existante.
    // ORGANISATIONPARTENAIRE uniquement.
    @PostMapping("/distribution/{aideDistribueeId}")
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<PreuveDistributionResponseDTO> ajouter(
            @PathVariable Integer aideDistribueeId,
            @Valid @RequestBody PreuveDistributionRequestDTO dto) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(preuveDistributionService.ajouter(
                        aideDistribueeId, dto));
    }

    // Récupérer une preuve par son identifiant.
    // Les quatre rôles peuvent consulter selon leurs droits.
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIAIRE')")
    public ResponseEntity<PreuveDistributionResponseDTO> getById(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                preuveDistributionService.getById(id));
    }

    // Récupérer toutes les preuves associées à une distribution.
    @GetMapping("/distribution/{aideDistribueeId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIAIRE')")
    public ResponseEntity<List<PreuveDistributionResponseDTO>>
    getByDistribution(@PathVariable Integer aideDistribueeId) {

        return ResponseEntity.ok(
                preuveDistributionService.getByDistribution(
                        aideDistribueeId));
    }

    // Supprimer une preuve.
    // ORGANISATIONPARTENAIRE uniquement.
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<Void> supprimer(@PathVariable Integer id) {

        preuveDistributionService.supprimer(id);

        return ResponseEntity.noContent().build();
    }

    // Téléverser un fichier justificatif.
    // ORGANISATIONPARTENAIRE uniquement.
    @PostMapping(
            value = "/distribution/{aideDistribueeId}/televerser",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<PreuveDistributionResponseDTO> televerser(
            @PathVariable Integer aideDistribueeId,
            @RequestParam("fichier") MultipartFile fichier,
            @RequestParam("typeMedia") TypeMedia typeMedia) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(preuveDistributionService.televerser(
                        aideDistribueeId, fichier, typeMedia));
    }
}
