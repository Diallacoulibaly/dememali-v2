
package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.OrganisationPartenaireResponseDTO;
import com.example.dememalibackend.service.LikeOrganisationService;

import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/likes-organisations")
@RequiredArgsConstructor
public class LikeOrganisationController {

    private final LikeOrganisationService likeOrganisationService;

    // Ajouter un like : DONATEUR uniquement
    @PostMapping("/{organisationId}")
    @PreAuthorize("hasRole('DONATEUR')")
    public ResponseEntity<Void> aimerOrganisation(
            @PathVariable Integer organisationId,
            @RequestParam Integer donateurId) {

        likeOrganisationService.aimerOrganisation(
                donateurId,
                organisationId
        );

        return ResponseEntity.ok().build();
    }

    // Retirer un like : DONATEUR uniquement
    @DeleteMapping("/{organisationId}")
    @PreAuthorize("hasRole('DONATEUR')")
    public ResponseEntity<Void> retirerLike(
            @PathVariable Integer organisationId,
            @RequestParam Integer donateurId) {

        likeOrganisationService.retirerLike(
                donateurId,
                organisationId
        );

        return ResponseEntity.noContent().build();
    }

    // Consulter les organisations aimées
    @GetMapping("/donateur/{donateurId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR')")
    public ResponseEntity<List<OrganisationPartenaireResponseDTO>>
    getOrganisationsAimees(@PathVariable Integer donateurId) {

        return ResponseEntity.ok(
                likeOrganisationService.getOrganisationsAimees(donateurId)
        );
    }
}
