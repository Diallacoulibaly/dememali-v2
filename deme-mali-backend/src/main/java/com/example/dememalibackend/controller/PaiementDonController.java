package com.example.dememalibackend.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import com.example.dememalibackend.dto.PaiementDonRequestDTO;
import com.example.dememalibackend.dto.PaiementDonResponseDTO;
import com.example.dememalibackend.service.PaiementDonService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
        import org.springframework.http.converter.HttpMessageNotReadableException;

@RestController
@RequestMapping("/api/paiements-dons")
@RequiredArgsConstructor
@PreAuthorize("hasRole('DONATEUR')")
public class PaiementDonController {

    private final PaiementDonService paiementDonService;

    @PostMapping("/simuler")
    public ResponseEntity<PaiementDonResponseDTO> effectuerPaiement(
            @Valid @RequestBody PaiementDonRequestDTO dto) {

        System.out.println("========== REQUÊTE PAIEMENT REÇUE ==========");
        System.out.println("Donateur ID : " + dto.getDonateurId());
        System.out.println("Demande ID : " + dto.getDemandeAideId());
        System.out.println("Montant : " + dto.getMontant());

        PaiementDonResponseDTO resultat =
                paiementDonService.effectuerPaiement(dto);

        return ResponseEntity.ok(resultat);
    }

    // Afficher l'erreur si Spring ne parvient pas à lire le JSON.
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<String> gererJsonInvalide(
            HttpMessageNotReadableException e) {

        e.printStackTrace();

        return ResponseEntity.badRequest()
                .body("Erreur de lecture JSON : " + e.getMessage());
    }
}
