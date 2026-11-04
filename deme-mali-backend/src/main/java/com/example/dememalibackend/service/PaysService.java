package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.PaysRequestDto;
import com.example.dememalibackend.dto.PaysResponseDto;

import java.util.List;

public interface PaysService {

    PaysResponseDto creer(PaysRequestDto dto);

    PaysResponseDto getById(Integer id);

    List<PaysResponseDto> getAll();

    PaysResponseDto modifier(Integer id, PaysRequestDto dto);

}

