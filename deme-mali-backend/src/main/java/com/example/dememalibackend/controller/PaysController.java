package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.PaysRequestDto;
import com.example.dememalibackend.dto.PaysResponseDto;
import com.example.dememalibackend.service.PaysService;

import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pays")
@RequiredArgsConstructor
public class PaysController {

    private final PaysService paysService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PaysResponseDto> creer(
            @RequestBody PaysRequestDto dto
    ) {
        return ResponseEntity.ok(
                paysService.creer(dto)
        );
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIAIRE', 'DONATEUR')")
    public ResponseEntity<PaysResponseDto> getById(
            @PathVariable Integer id
    ) {
        return ResponseEntity.ok(
                paysService.getById(id)
        );
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE', 'BENEFICIAIRE', 'DONATEUR')")
    public ResponseEntity<List<PaysResponseDto>> getAll() {

        return ResponseEntity.ok(
                paysService.getAll()
        );
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PaysResponseDto> modifier(
            @PathVariable Integer id,
            @RequestBody PaysRequestDto dto
    ) {
        return ResponseEntity.ok(
                paysService.modifier(id, dto)
        );
    }
}