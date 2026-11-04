package com.example.dememalibackend.dto;

import lombok.Setter;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ImageDemandeRequestDTO {

    private String nomFichier;
    private String cheminFichier;
    private Integer demandeAideId;
}
