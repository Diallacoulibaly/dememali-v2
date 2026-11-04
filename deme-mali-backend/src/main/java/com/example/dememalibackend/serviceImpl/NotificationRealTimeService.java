package com.example.dememalibackend.serviceImpl;

import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@Service
public class NotificationRealTimeService {

    private final Map<String, List<SseEmitter>> emitters = new ConcurrentHashMap<>();
    private final Map<String, List<Map<String, Object>>> notificationHistory = new ConcurrentHashMap<>();

    public SseEmitter subscribe(String key) {
        String safeKey = (key == null || key.isBlank()) ? "ALL" : key.trim();
        SseEmitter emitter = new SseEmitter(30 * 60 * 1000L); // 30 minutes

        emitters.computeIfAbsent(safeKey, k -> new CopyOnWriteArrayList<>()).add(emitter);

        emitter.onCompletion(() -> removeEmitter(safeKey, emitter));
        emitter.onTimeout(() -> removeEmitter(safeKey, emitter));
        emitter.onError(e -> removeEmitter(safeKey, emitter));

        try {
            Map<String, Object> welcome = new HashMap<>();
            welcome.put("type", "CONNECTED");
            welcome.put("message", "Connecté au flux de notification en temps réel");
            welcome.put("timestamp", LocalDateTime.now().toString());
            emitter.send(SseEmitter.event().name("init").data(welcome));
        } catch (IOException e) {
            removeEmitter(safeKey, emitter);
        }

        return emitter;
    }

    private void removeEmitter(String key, SseEmitter emitter) {
        List<SseEmitter> list = emitters.get(key);
        if (list != null) {
            list.remove(emitter);
            if (list.isEmpty()) {
                emitters.remove(key);
            }
        }
    }

    public void notifierValidationOrganisation(Integer id, String nomOrganisation, String telephone) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", "VALIDATION_COMPTE");
        payload.put("organisationId", id);
        payload.put("nomOrganisation", nomOrganisation != null ? nomOrganisation : "Organisation");
        payload.put("telephone", telephone);
        payload.put("statut", "VALIDEE");
        payload.put("titre", "Compte Partenaire Validé !");
        payload.put("message", "Félicitations ! Votre compte organisation partenaire (" + (nomOrganisation != null ? nomOrganisation : "") + ") a été validé avec succès par l'administrateur. Vous avez désormais plein accès à votre tableau de bord.");
        payload.put("timestamp", LocalDateTime.now().toString());

        enregistrerEtDiffuser(telephone, payload);
    }

    public void notifierRejetOrganisation(Integer id, String nomOrganisation, String telephone) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", "REJET_COMPTE");
        payload.put("organisationId", id);
        payload.put("nomOrganisation", nomOrganisation != null ? nomOrganisation : "Organisation");
        payload.put("telephone", telephone);
        payload.put("statut", "REJETEE");
        payload.put("titre", "Compte Partenaire Refusé");
        payload.put("message", "Votre demande d'inscription pour l'organisation (" + (nomOrganisation != null ? nomOrganisation : "") + ") a été refusée par l'administrateur.");
        payload.put("timestamp", LocalDateTime.now().toString());

        enregistrerEtDiffuser(telephone, payload);
    }

    private void enregistrerEtDiffuser(String telephone, Map<String, Object> payload) {
        if (telephone != null && !telephone.isBlank()) {
            notificationHistory.computeIfAbsent(telephone.trim(), k -> new CopyOnWriteArrayList<>()).add(0, payload);
        }
        notificationHistory.computeIfAbsent("ALL", k -> new CopyOnWriteArrayList<>()).add(0, payload);

        if (telephone != null && emitters.containsKey(telephone.trim())) {
            envoyerA(emitters.get(telephone.trim()), payload);
        }

        if (emitters.containsKey("ALL")) {
            envoyerA(emitters.get("ALL"), payload);
        }
    }

    private void envoyerA(List<SseEmitter> list, Map<String, Object> payload) {
        if (list == null) return;
        List<SseEmitter> deadEmitters = new ArrayList<>();
        for (SseEmitter emitter : list) {
            try {
                emitter.send(SseEmitter.event().name("notification").data(payload));
            } catch (Exception e) {
                deadEmitters.add(emitter);
            }
        }
        list.removeAll(deadEmitters);
    }

    public List<Map<String, Object>> getHistorique(String key) {
        String safeKey = (key == null || key.isBlank()) ? "ALL" : key.trim();
        List<Map<String, Object>> hist = notificationHistory.get(safeKey);
        return hist != null ? new ArrayList<>(hist) : Collections.emptyList();
    }
}