
package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.TypeMedia;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PreuveDistributionResponseDTO {

    private Integer id;

    private String nomFichier;

    private String urlFichier;

    private TypeMedia typeMedia;
}
