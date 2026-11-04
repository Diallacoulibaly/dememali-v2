package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.TypeJustificatifRequestDTO;
import com.example.dememalibackend.dto.TypeJustificatifResponseDTO;
import com.example.dememalibackend.service.TypeJustificatifService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/types-justificatif")
@RequiredArgsConstructor
public class TypeJustificatifController {

    private final TypeJustificatifService service;

    // ADMIN uniquement
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public TypeJustificatifResponseDTO creer(
            @RequestBody TypeJustificatifRequestDTO dto) {

        return service.creer(dto);
    }

    // Tous les rôles
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIAIRE', 'DONATEUR')")
    public TypeJustificatifResponseDTO getById(
            @PathVariable Integer id) {

        return service.getById(id);
    }

    // Tous les rôles
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIAIRE', 'DONATEUR')")
    public List<TypeJustificatifResponseDTO> getAll() {

        return service.getAll();
    }

    // ADMIN uniquement
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public TypeJustificatifResponseDTO modifier(
            @PathVariable Integer id,
            @RequestBody TypeJustificatifRequestDTO dto) {

        return service.modifier(id, dto);
    }
}