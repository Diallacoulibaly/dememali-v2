package com.example.dememalibackend.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class JustificatifRequestDTO {

    private String nomFichier;
    private String cheminFichier;
    private Integer typeJustificatifId;
    private Integer demandeAideId;
}
