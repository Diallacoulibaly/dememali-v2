
package com.example.dememalibackend.service;

import com.example.dememalibackend.Enum.TypeMedia;
import com.example.dememalibackend.dto.PreuveDistributionRequestDTO;
import com.example.dememalibackend.dto.PreuveDistributionResponseDTO;

import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface PreuveDistributionService {

    PreuveDistributionResponseDTO ajouter(
            Integer aideDistribueeId,
            PreuveDistributionRequestDTO dto
    );

    PreuveDistributionResponseDTO televerser(
            Integer aideDistribueeId,
            MultipartFile fichier,
            TypeMedia typeMedia
    );

    PreuveDistributionResponseDTO getById(Integer id);

    List<PreuveDistributionResponseDTO> getByDistribution(
            Integer aideDistribueeId
    );

    void supprimer(Integer id);
}
