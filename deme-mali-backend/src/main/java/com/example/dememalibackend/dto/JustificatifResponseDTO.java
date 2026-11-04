package com.example.dememalibackend.dto;

import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class JustificatifResponseDTO {

    private Integer id;
    private String nomFichier;
    private String cheminFichier;
    private LocalDate dateAjout;

    private Integer typeJustificatifId;
    private Integer demandeAideId;
}