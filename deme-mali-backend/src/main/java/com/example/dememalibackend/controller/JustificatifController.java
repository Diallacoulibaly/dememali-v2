package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.JustificatifRequestDTO;
import com.example.dememalibackend.dto.JustificatifResponseDTO;
import com.example.dememalibackend.service.JustificatifService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/justificatifs")
@RequiredArgsConstructor
public class JustificatifController {

    private final JustificatifService service;

    // Organisation et bénéficiaire uniquement
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAnyRole('ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public List<JustificatifResponseDTO> creer(
            @RequestPart("fichiers") List<MultipartFile> fichiers,
            @RequestParam("typeJustificatifId") Integer typeJustificatifId,
            @RequestParam("demandeAideId") Integer demandeAideId) {

        JustificatifRequestDTO dto = new JustificatifRequestDTO();
        dto.setTypeJustificatifId(typeJustificatifId);
        dto.setDemandeAideId(demandeAideId);

        return service.creer(dto, fichiers);
    }

    // Tous les rôles : accès vérifié dans le service
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public JustificatifResponseDTO getById(
            @PathVariable Integer id) {

        return service.getById(id);
    }

    // ADMIN, organisation et bénéficiaire uniquement
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public List<JustificatifResponseDTO> getAll() {

        return service.getAll();
    }

    // Tous les rôles : accès vérifié dans le service
    @GetMapping("/demande/{demandeAideId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE', 'DONATEUR')")
    public List<JustificatifResponseDTO> getByDemande(
            @PathVariable Integer demandeAideId) {

        return service.getByDemande(demandeAideId);
    }

    // Organisation et bénéficiaire uniquement
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public JustificatifResponseDTO modifier(
            @PathVariable Integer id,
            @RequestBody JustificatifRequestDTO dto) {

        return service.modifier(id, dto);
    }

    // Organisation et bénéficiaire uniquement
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public void supprimer(
            @PathVariable Integer id) {

        service.supprimer(id);
    }
}