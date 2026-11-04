package com.example.dememalibackend.dto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor

public class ImageDemandeResponseDTO {

    private Integer id;
    private String nomFichier;
    private String cheminFichier;
    private LocalDate dateAjout;
    private Integer demandeAideId;
}
