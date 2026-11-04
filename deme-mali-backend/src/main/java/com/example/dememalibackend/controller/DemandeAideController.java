
package com.example.dememalibackend.controller;

import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.dto.DemandeAideRequestDTO;
import com.example.dememalibackend.dto.DemandeAideResponseDTO;
import com.example.dememalibackend.service.DemandeAideService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/demandes-aide")
@RequiredArgsConstructor
public class DemandeAideController {

    private final DemandeAideService demandeAideService;

    // Création : Organisation partenaire ou Bénéficiaire
    @PostMapping
    @PreAuthorize("hasAnyRole('ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<DemandeAideResponseDTO> creer(
            @RequestBody DemandeAideRequestDTO dto) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(demandeAideService.creer(dto));
    }

    // Consultation d'une demande
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<DemandeAideResponseDTO> getById(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                demandeAideService.getById(id)
        );
    }

    // Consultation de toutes les demandes selon les droits
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<List<DemandeAideResponseDTO>> getAll() {

        return ResponseEntity.ok(
                demandeAideService.getAll()
        );
    }

    // Modification : Organisation partenaire ou propriétaire bénéficiaire
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<DemandeAideResponseDTO> modifier(
            @PathVariable Integer id,
            @RequestBody DemandeAideRequestDTO dto) {

        return ResponseEntity.ok(
                demandeAideService.modifier(id, dto)
        );
    }

    // Validation : Organisation partenaire uniquement
    @PatchMapping("/{id}/valider")
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<DemandeAideResponseDTO> valider(
            @PathVariable Integer id) {

        return ResponseEntity.ok(
                demandeAideService.valider(id)
        );
    }

    // Rejet : Organisation partenaire uniquement
    @PatchMapping("/{id}/rejeter")
    @PreAuthorize("hasRole('ORGANISATIONPARTENAIRE')")
    public ResponseEntity<DemandeAideResponseDTO> rejeter(
            @PathVariable Integer id,
            @RequestParam String motif) {

        return ResponseEntity.ok(
                demandeAideService.rejeter(id, motif)
        );
    }

    // Consultation selon le statut
    @GetMapping("/statut/{statut}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<List<DemandeAideResponseDTO>> getByStatut(
            @PathVariable StatutDemande statut) {

        return ResponseEntity.ok(
                demandeAideService.getByStatut(statut)
        );
    }

    // Consultation des demandes d'un bénéficiaire
    @GetMapping("/beneficiaire/{beneficiaireId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<List<DemandeAideResponseDTO>> getByBeneficiaire(
            @PathVariable Integer beneficiaireId) {

        return ResponseEntity.ok(
                demandeAideService.getByBeneficiaire(beneficiaireId)
        );
    }

    // Consultation des demandes d'une organisation
    @GetMapping("/organisation/{organisationPartenaireId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<List<DemandeAideResponseDTO>> getByOrganisation(
            @PathVariable Integer organisationPartenaireId) {

        return ResponseEntity.ok(
                demandeAideService.getByOrganisation(
                        organisationPartenaireId
                )
        );
    }

    // Consultation des demandes par catégorie
    @GetMapping("/categorie/{categorieDemandeId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<List<DemandeAideResponseDTO>> getByCategorie(
            @PathVariable Integer categorieDemandeId) {

        return ResponseEntity.ok(
                demandeAideService.getByCategorie(
                        categorieDemandeId
                )
        );
    }

    // Demandes disponibles pour les dons
    @GetMapping("/disponibles-pour-don")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<List<DemandeAideResponseDTO>>
    getDemandesDisponiblesPourDon() {

        return ResponseEntity.ok(
                demandeAideService.getDemandesDisponiblesPourDon()
        );
    }

    // Demandes disponibles pour les dons d'une organisation
    @GetMapping("/disponibles-pour-don/organisation/{organisationId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public List<DemandeAideResponseDTO> getDemandesDisponiblesPourDon(
            @PathVariable Integer organisationId) {

        return demandeAideService.getDemandesDisponiblesPourDon(
                organisationId
        );
    }

    // Demandes validées dont la collecte est terminée
    @GetMapping("/terminees-pour-aide-distribuee/organisation/{organisationId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public List<DemandeAideResponseDTO> getDemandesTermineesPourAideDistribuee(
            @PathVariable Integer organisationId) {

        return demandeAideService
                .getDemandesTermineesPourAideDistribuee(organisationId);
    }

    // Demandes pour la planification
    @GetMapping("/planification/organisation/{organisationId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'DONATEUR', 'BENEFICIARE')")
    public ResponseEntity<List<DemandeAideResponseDTO>> getDemandesPourPlanification(
            @PathVariable Integer organisationId) {

        return ResponseEntity.ok(
                demandeAideService.getDemandesPourPlanification(
                        organisationId
                )
        );
    }
}
