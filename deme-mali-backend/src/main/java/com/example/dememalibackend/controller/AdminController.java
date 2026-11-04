package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.AdminDTO;
import com.example.dememalibackend.dto.AdminResponseDTO;
import com.example.dememalibackend.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;

import java.util.List;

@RestController
@RequestMapping("/api/admins")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    // Afficher tous les administrateurs
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public ResponseEntity<List<AdminResponseDTO>> afficherAdmins() {

        return ResponseEntity.ok(
                adminService.afficherAdmins()
        );
    }

    // Afficher un administrateur par son ID
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/{id}")
    public ResponseEntity<AdminResponseDTO> afficherAdmin(
            @PathVariable int id
    ) {

        return ResponseEntity.ok(
                adminService.afficherAdmin(id)
        );
    }

    // Ajouter un administrateur
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping
    public ResponseEntity<AdminResponseDTO> ajouterAdmin(
            @RequestBody AdminDTO dto
    ) {

        return ResponseEntity.ok(
                adminService.ajouterAdmin(dto)
        );
    }

    // Modifier un administrateur
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}")
    public ResponseEntity<AdminResponseDTO> modifierAdmin(
            @PathVariable int id,
            @RequestBody AdminDTO dto
    ) {

        return ResponseEntity.ok(
                adminService.modifierAdmin(id, dto)
        );
    }

    // Suppression interdite pour tous les rôles
    @PreAuthorize("denyAll()")
    @DeleteMapping("/{id}")
    public ResponseEntity<String> supprimerAdmin(
            @PathVariable int id
    ) {

        adminService.supprimerAdmin(id);

        return ResponseEntity.ok(
                "Administrateur supprimé avec succès"
        );
    }
}