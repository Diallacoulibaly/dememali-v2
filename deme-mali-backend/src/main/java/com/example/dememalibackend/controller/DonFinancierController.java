
package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.ComptabiliteDonsResponseDTO;
import com.example.dememalibackend.dto.DonFinancierRequestDTO;
import com.example.dememalibackend.dto.DonFinancierResponseDTO;
import com.example.dememalibackend.service.DonFinancierService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/dons-financiers")
@RequiredArgsConstructor
public class DonFinancierController {

    private final DonFinancierService donFinancierService;

    @PostMapping
    @PreAuthorize("hasRole('DONATEUR')")
    public ResponseEntity<DonFinancierResponseDTO> creer(
            @Valid @RequestBody DonFinancierRequestDTO dto) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(donFinancierService.creer(dto));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIAIRE', 'ADMIN')")
    public ResponseEntity<DonFinancierResponseDTO> getById(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                donFinancierService.getById(id)
        );
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<DonFinancierResponseDTO>> getAll() {

        return ResponseEntity.ok(
                donFinancierService.getAll()
        );
    }

    @GetMapping("/donateur/{donateurId}")
    @PreAuthorize("hasAnyRole('DONATEUR', 'ADMIN')")
    public ResponseEntity<List<DonFinancierResponseDTO>> getByDonateur(
            @PathVariable Integer donateurId) {

        return ResponseEntity.ok(
                donFinancierService.getByDonateur(donateurId)
        );
    }

    @GetMapping("/demande/{demandeAideId}")
    @PreAuthorize("hasAnyRole('ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIAIRE', 'ADMIN')")
    public ResponseEntity<List<DonFinancierResponseDTO>> getByDemande(
            @PathVariable Integer demandeAideId) {

        return ResponseEntity.ok(
                donFinancierService.getByDemande(demandeAideId)
        );
    }

    @GetMapping("/statistiques/total")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Double> getTotalDons() {

        return ResponseEntity.ok(
                donFinancierService.getTotalDons()
        );
    }

    @GetMapping("/statistiques/affectes")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIAIRE')")
    public ResponseEntity<Double> getTotalDonsAffectes() {

        return ResponseEntity.ok(
                donFinancierService.getTotalDonsAffectes()
        );
    }

    @GetMapping("/statistiques/generaux")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<Double> getTotalDonsGeneraux() {

        return ResponseEntity.ok(
                donFinancierService.getTotalDonsGeneraux()
        );
    }

    @GetMapping("/organisation/{organisationId}/total")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<Double> getTotalDonsOrganisation(
            @PathVariable Integer organisationId) {

        return ResponseEntity.ok(
                donFinancierService
                        .getTotalDonsOrganisation(
                                organisationId
                        )
        );
    }

    @GetMapping("/organisation/{organisationId}/comptabilite")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<ComptabiliteDonsResponseDTO>
    getComptabiliteOrganisation(
            @PathVariable Integer organisationId) {

        return ResponseEntity.ok(
                donFinancierService
                        .getComptabiliteOrganisation(
                                organisationId
                        )
        );
    }

    @GetMapping("/organisation/{organisationId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<List<DonFinancierResponseDTO>>
    getDonsOrganisation(
            @PathVariable Integer organisationId) {

        return ResponseEntity.ok(
                donFinancierService
                        .getDonsOrganisation(
                                organisationId
                        )
        );
    }

    @GetMapping("/demande/{demandeAideId}/verifier-montant")
    @PreAuthorize("hasRole('DONATEUR')")
    public ResponseEntity<?> verifierMontant(
            @PathVariable Integer demandeAideId,
            @RequestParam Double montant) {

        donFinancierService.verifierMontant(
                demandeAideId, montant);

        return ResponseEntity.ok(
                "Montant accepté. Vous pouvez continuer vers le paiement.");
    }

    // Dons qui peuvent être affectés par une organisation :
    // ce sont des dons qui lui sont liés, car ils sont destinés à la soutenir.
    @GetMapping("/affectables/organisation/{organisationId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<List<DonFinancierResponseDTO>> getDonsAffectablesParOrganisation(
            @PathVariable Integer organisationId) {

        List<DonFinancierResponseDTO> dons =
                donFinancierService.getDonsAffectablesParOrganisation(organisationId);

        return ResponseEntity.ok(dons);
    }
}
