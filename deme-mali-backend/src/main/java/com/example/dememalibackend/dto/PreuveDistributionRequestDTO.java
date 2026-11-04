
package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.TypeMedia;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PreuveDistributionRequestDTO {

    @NotBlank
    private String nomFichier;

    @NotBlank
    private String urlFichier;

    @NotNull
    private TypeMedia typeMedia;
}
