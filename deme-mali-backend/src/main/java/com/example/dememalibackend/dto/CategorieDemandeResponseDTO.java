package com.example.dememalibackend.dto;

    import lombok.*;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public class CategorieDemandeResponseDTO {

        private Integer id;

        private String nom;
    }
