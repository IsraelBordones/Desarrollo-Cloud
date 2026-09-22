package com.pedidos360.notificaciones.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.pedidos360.notificaciones.dto.NotificacionDTO;
import com.pedidos360.notificaciones.model.Notificacion;
import com.pedidos360.notificaciones.repository.NotificacionRepository;

/**
 * Business logic for notifications. In a production system this would push to
 * an email/SMS provider or an SNS topic; here it persists an audit record.
 */
@Service
public class NotificacionService {

    private final NotificacionRepository repository;

    public NotificacionService(NotificacionRepository repository) {
        this.repository = repository;
    }

    public NotificacionDTO notify(NotificacionDTO dto) {
        Notificacion entity = new Notificacion();
        entity.setPedidoId(dto.getPedidoId());
        entity.setMensaje(dto.getMensaje());
        entity.setCanal(dto.getCanal() != null ? dto.getCanal() : "EMAIL");
        entity.setEstado("ENVIADA");
        return toDto(repository.save(entity));
    }

    public List<NotificacionDTO> history() {
        return repository.findAllByOrderByFechaDesc().stream()
                .map(this::toDto).collect(Collectors.toList());
    }

    private NotificacionDTO toDto(Notificacion n) {
        NotificacionDTO dto = new NotificacionDTO();
        dto.setId(n.getId());
        dto.setPedidoId(n.getPedidoId());
        dto.setMensaje(n.getMensaje());
        dto.setCanal(n.getCanal());
        dto.setEstado(n.getEstado());
        dto.setFecha(n.getFecha());
        return dto;
    }
}
