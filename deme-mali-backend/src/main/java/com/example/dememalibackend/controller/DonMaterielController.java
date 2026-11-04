package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.DonMaterielRequestDTO;
import com.example.dememalibackend.dto.DonMaterielResponseDTO;
import com.example.dememalibackend.service.DonMaterielService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/dons-materiels")
@RequiredArgsConstructor
public class DonMaterielController {

    private final DonMaterielService donMaterielService;

    @PostMapping
    @PreAuthorize("hasRole('DONATEUR')")
    public DonMaterielResponseDTO creer(@RequestBody DonMaterielRequestDTO dto) {
        return donMaterielService.creer(dto);
    }

    @GetMapping("/donateur/{donateurId}")
    @PreAuthorize("hasAnyRole('DONATEUR', 'ADMIN')")
    public List<DonMaterielResponseDTO> getByDonateur(@PathVariable Integer donateurId) {
        return donMaterielService.getByDonateur(donateurId);
    }

    @GetMapping("/demande/{demandeAideId}")
    @PreAuthorize("hasAnyRole('DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIAIRE', 'ADMIN')")
    public List<DonMaterielResponseDTO> getByDemande(@PathVariable Integer demandeAideId) {
        return donMaterielService.getByDemande(demandeAideId);
    }

    @PutMapping("/{donId}/reception")
    @PreAuthorize("hasAnyRole('ORGANISATIONPARTENAIRE', 'ADMIN')")
    public DonMaterielResponseDTO confirmerReception(
            @PathVariable Integer donId,
            @RequestParam Integer quantiteRecue) {
        return donMaterielService.confirmerReception(donId, quantiteRecue);
    }

    @PutMapping("/{donId}/refus")
    @PreAuthorize("hasAnyRole('ORGANISATIONPARTENAIRE', 'ADMIN')")
    public DonMaterielResponseDTO refuser(
            @PathVariable Integer donId,
            @RequestParam String motifRefus) {
        return donMaterielService.refuser(donId, motifRefus);
    }

    @GetMapping("/organisation/{organisationId}")
    @PreAuthorize("hasAnyRole('ORGANISATIONPARTENAIRE', 'ADMIN')")
    public List<DonMaterielResponseDTO> getByOrganisation(@PathVariable Integer organisationId) {
        return donMaterielService.getByOrganisation(organisationId);
    }

    @GetMapping("/donateur/{donateurId}/statistiques/valeur")
    @PreAuthorize("hasAnyRole('DONATEUR', 'ADMIN')")
    public ResponseEntity<Double> getValeurMaterielleRecue(
            @PathVariable Integer donateurId,
            @RequestParam LocalDate debut,
            @RequestParam LocalDate fin) {
        return ResponseEntity.ok(
                donMaterielService.calculerValeurMaterielleRecueParPeriode(donateurId, debut, fin)
        );
    }

    @GetMapping("/affectables/organisation/{organisationId}")
    @PreAuthorize("hasAnyRole('ORGANISATIONPARTENAIRE', 'ADMIN')")
    public ResponseEntity<List<DonMaterielResponseDTO>> getDonsAffectablesParOrganisation(
            @PathVariable Integer organisationId) {
        List<DonMaterielResponseDTO> dons =
                donMaterielService.getDonsAffectablesParOrganisation(organisationId);
        return ResponseEntity.ok(dons);
    }
}