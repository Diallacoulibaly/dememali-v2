package com.example.dememalibackend.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategorieDemandeRequestDTO {

    @NotBlank(message = "Le nom de la catégorie est obligatoire")
    private String nom;
}