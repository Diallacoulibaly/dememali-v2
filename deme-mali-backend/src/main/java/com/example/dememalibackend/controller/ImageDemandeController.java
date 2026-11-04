
package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.ImageDemandeResponseDTO;
import com.example.dememalibackend.service.ImageDemandeService;

import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/images-demandes")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ImageDemandeController {

    private final ImageDemandeService imageDemandeService;

    // Ajouter une image : ORGANISATIONPARTENAIRE uniquement
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<ImageDemandeResponseDTO> creer(
            @RequestParam("demandeAideId") Integer demandeAideId,
            @RequestParam("fichier") MultipartFile fichier) {

        ImageDemandeResponseDTO image =
                imageDemandeService.creer(demandeAideId, fichier);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(image);
    }

    // Consulter une image
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public ResponseEntity<ImageDemandeResponseDTO> getById(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                imageDemandeService.getById(id)
        );
    }

    // Consulter les images accessibles
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public ResponseEntity<List<ImageDemandeResponseDTO>> getAll() {

        return ResponseEntity.ok(
                imageDemandeService.getAll()
        );
    }

    // Consulter les images d'une demande
    @GetMapping("/demande/{demandeAideId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public ResponseEntity<List<ImageDemandeResponseDTO>> getByDemande(
            @PathVariable Integer demandeAideId) {

        return ResponseEntity.ok(
                imageDemandeService.getByDemande(demandeAideId)
        );
    }

    // Remplacer une image : ADMIN ou organisation propriétaire
    @PutMapping(
            value = "/{id}/fichier",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<ImageDemandeResponseDTO> modifierImage(
            @PathVariable Integer id,
            @RequestParam("fichier") MultipartFile fichier) {

        return ResponseEntity.ok(
                imageDemandeService.modifierImage(id, fichier)
        );
    }

    // Supprimer une image : ADMIN ou organisation propriétaire
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<Void> supprimer(
            @PathVariable Integer id) {

        imageDemandeService.supprimer(id);

        return ResponseEntity.noContent().build();
    }
}
