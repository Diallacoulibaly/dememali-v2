package com.example.dememalibackend.controller;

import com.example.dememalibackend.serviceImpl.NotificationRealTimeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationRealTimeService notificationService;

    @GetMapping(value = "/stream/{telephone}", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public SseEmitter streamParTelephone(@PathVariable String telephone) {
        return notificationService.subscribe(telephone);
    }

    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public SseEmitter streamGlobal() {
        return notificationService.subscribe("ALL");
    }

    @GetMapping("/user/{telephone}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR', 'ORGANISATIONPARTENAIRE', 'BENEFICIARE')")
    public ResponseEntity<List<Map<String, Object>>> getHistorique(@PathVariable String telephone) {
        return ResponseEntity.ok(notificationService.getHistorique(telephone));
    }
}