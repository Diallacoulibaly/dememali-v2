package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.OrganisationPartenaireRequestDTO;
import com.example.dememalibackend.exceptions.GlobalExceptionHandler;
import com.example.dememalibackend.service.OrganisationPartenaireService;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.multipart.MultipartFile;
import tools.jackson.databind.ObjectMapper;

import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class OrganisationPartenaireControllerMultipartTest {

    private final OrganisationPartenaireService service = mock(OrganisationPartenaireService.class);
    private final MockMvc mvc = MockMvcBuilders
            .standaloneSetup(new OrganisationPartenaireController(service, new ObjectMapper()))
            .setControllerAdvice(new GlobalExceptionHandler())
            .build();

    @Test
    void accepteLeJsonOctetStreamAvecUneImage() throws Exception {
        MockMultipartFile organisation = new MockMultipartFile(
                "organisation", "organisation.json", "application/octet-stream",
                "{\"nomOrganisation\":\"Association A\",\"motDePasse\":\"secret123\"}"
                        .getBytes(StandardCharsets.UTF_8));
        MockMultipartFile image = new MockMultipartFile(
                "file", "logo.png", "image/png", new byte[]{(byte) 0x89, 0x50, 0x4e, 0x47});

        mvc.perform(multipart("/api/organisations-partenaires")
                        .file(organisation)
                        .file(image))
                .andExpect(status().isCreated());

        ArgumentCaptor<OrganisationPartenaireRequestDTO> dto =
                ArgumentCaptor.forClass(OrganisationPartenaireRequestDTO.class);
        ArgumentCaptor<MultipartFile> fichier = ArgumentCaptor.forClass(MultipartFile.class);
        verify(service).creer(dto.capture(), fichier.capture());
        assertEquals("Association A", dto.getValue().getNomOrganisation());
        assertEquals("logo.png", fichier.getValue().getOriginalFilename());
    }

    @Test
    void accepteToujoursLeJsonAvecSonTypeHabituel() throws Exception {
        MockMultipartFile organisation = new MockMultipartFile(
                "organisation", "organisation.json", "application/json",
                "{\"nomOrganisation\":\"Association B\"}"
                        .getBytes(StandardCharsets.UTF_8));

        mvc.perform(multipart("/api/organisations-partenaires").file(organisation))
                .andExpect(status().isCreated());

        ArgumentCaptor<OrganisationPartenaireRequestDTO> dto =
                ArgumentCaptor.forClass(OrganisationPartenaireRequestDTO.class);
        verify(service).creer(dto.capture(), org.mockito.ArgumentMatchers.isNull());
        assertEquals("Association B", dto.getValue().getNomOrganisation());
    }

    @Test
    void refuseUnJsonInvalideAvecUneErreurClaire() throws Exception {
        MockMultipartFile organisation = new MockMultipartFile(
                "organisation", "organisation.json", "application/octet-stream",
                "pas du json".getBytes(StandardCharsets.UTF_8));

        mvc.perform(multipart("/api/organisations-partenaires").file(organisation))
                .andExpect(status().isBadRequest());
        verifyNoInteractions(service);
    }
}
