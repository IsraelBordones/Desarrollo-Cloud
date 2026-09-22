package com.pedidos360.notificaciones.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.pedidos360.notificaciones.dto.NotificacionDTO;
import com.pedidos360.notificaciones.service.NotificacionService;

import jakarta.validation.Valid;

/**
 * REST controller for order notifications.
 */
@RestController
@RequestMapping("/notificaciones")
public class NotificacionController {

    private final NotificacionService service;

    public NotificacionController(NotificacionService service) {
        this.service = service;
    }

    @PostMapping("/notify")
    public ResponseEntity<NotificacionDTO> notify(@Valid @RequestBody NotificacionDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.notify(dto));
    }

    @GetMapping("/history")
    public List<NotificacionDTO> history() {
        return service.history();
    }
}
