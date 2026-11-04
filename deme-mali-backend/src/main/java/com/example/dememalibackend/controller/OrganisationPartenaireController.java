
package com.example.dememalibackend.controller;

import com.example.dememalibackend.Enum.StatutValidation;
import com.example.dememalibackend.dto.BeneficiaireParticulierRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireParticulierResponseDTO;
import com.example.dememalibackend.dto.OrganisationPartenaireRequestDTO;
import com.example.dememalibackend.dto.OrganisationPartenaireResponseDTO;
import com.example.dememalibackend.exceptions.BadRequestException;
import com.example.dememalibackend.service.OrganisationPartenaireService;
import tools.jackson.databind.ObjectMapper;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/organisations-partenaires")
@RequiredArgsConstructor
public class OrganisationPartenaireController {

    private final OrganisationPartenaireService organisationPartenaireService;
    private final ObjectMapper objectMapper;

    // Créer une organisation partenaire
    @PostMapping(consumes = {
            org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE
    })
    //@PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<OrganisationPartenaireResponseDTO> creer(
            @RequestPart("organisation") String organisationJson,
            @RequestPart(value = "file", required = false)
            org.springframework.web.multipart.MultipartFile file) {

        OrganisationPartenaireRequestDTO dto;
        try {
            dto = objectMapper.readValue(organisationJson, OrganisationPartenaireRequestDTO.class);
        } catch (Exception e) {
            throw new BadRequestException("La partie organisation doit contenir un objet JSON valide.");
        }
        if (dto == null) {
            throw new BadRequestException("La partie organisation doit contenir un objet JSON valide.");
        }

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(organisationPartenaireService.creer(dto, file));
    }

    // Liste des organisations validées avec leurs likes
    @GetMapping("/liste-avec-likes")
    @PreAuthorize("hasAnyRole('DONATEUR', 'ADMIN')")
    public ResponseEntity<List<OrganisationPartenaireResponseDTO>>
    getAllAvecLikes(
            @RequestParam(required = false) Integer donateurId) {

        return ResponseEntity.ok(
                organisationPartenaireService.getAllAvecLikes(donateurId)
        );
    }

    // Consulter une organisation
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<OrganisationPartenaireResponseDTO> getById(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                organisationPartenaireService.getById(id)
        );
    }

    // Consulter toutes les organisations
    @GetMapping
    public ResponseEntity<List<OrganisationPartenaireResponseDTO>> getAll() {

        return ResponseEntity.ok(
                organisationPartenaireService.getAll()
        );
    }

    // Modifier une organisation
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<?> modifier(
            @PathVariable Integer id,
            @RequestBody OrganisationPartenaireRequestDTO dto) {

        try {
            return ResponseEntity.ok(
                    organisationPartenaireService.modifier(id, dto)
            );

        } catch (BadRequestException e) {
            return ResponseEntity
                    .badRequest()
                    .body(Map.of("message", e.getMessage()));
        }
    }

    // Changer le statut d'une organisation
    @PatchMapping("/{id}/statut")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<OrganisationPartenaireResponseDTO> changerStatut(
            @PathVariable Integer id,
            @RequestParam StatutValidation statut) {

        return ResponseEntity.ok(
                organisationPartenaireService.changerStatut(id, statut)
        );
    }

    // Enregistrer un bénéficiaire particulier
    @PostMapping("/{organisationId}/beneficiaires/particuliers")
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<BeneficiaireParticulierResponseDTO>
    enregistrerBeneficiaireParticulier(
            @PathVariable Integer organisationId,
            @Valid @RequestBody BeneficiaireParticulierRequestDTO dto) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        organisationPartenaireService
                                .enregistrerBeneficiaireParticulier(
                                        organisationId,
                                        dto
                                )
                );
    }
}
