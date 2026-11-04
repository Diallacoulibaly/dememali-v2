package com.example.dememalibackend.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ComptabiliteDonsResponseDTO {

    private Double totalDons;

    private Double totalDonsAffectes;

    private Double totalDonsGeneraux;

    private Double totalDonsOrganisation;
}