package com.pedidos360.pedidos.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.pedidos360.pedidos.dto.PedidoDTO;
import com.pedidos360.pedidos.model.Pedido;
import com.pedidos360.pedidos.repository.PedidoRepository;

/**
 * Business logic for orders.
 */
@Service
public class PedidoService {

    private final PedidoRepository repository;

    public PedidoService(PedidoRepository repository) {
        this.repository = repository;
    }

    public List<PedidoDTO> findAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    public PedidoDTO findById(Long id) {
        return toDto(repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Pedido " + id + " not found")));
    }

    public PedidoDTO create(PedidoDTO dto) {
        Pedido entity = toEntity(dto);
        entity.setId(null);
        return toDto(repository.save(entity));
    }

    public PedidoDTO update(Long id, PedidoDTO dto) {
        Pedido entity = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Pedido " + id + " not found"));
        entity.setClienteId(dto.getClienteId());
        entity.setProductos(dto.getProductos());
        entity.setTotal(dto.getTotal());
        if (dto.getEstado() != null) {
            entity.setEstado(dto.getEstado());
        }
        return toDto(repository.save(entity));
    }

    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Pedido " + id + " not found");
        }
        repository.deleteById(id);
    }

    private PedidoDTO toDto(Pedido p) {
        PedidoDTO dto = new PedidoDTO();
        dto.setId(p.getId());
        dto.setClienteId(p.getClienteId());
        dto.setProductos(p.getProductos());
        dto.setEstado(p.getEstado());
        dto.setTotal(p.getTotal());
        dto.setFecha(p.getFecha());
        return dto;
    }

    private Pedido toEntity(PedidoDTO dto) {
        Pedido p = new Pedido();
        p.setId(dto.getId());
        p.setClienteId(dto.getClienteId());
        p.setProductos(dto.getProductos());
        p.setEstado(dto.getEstado());
        p.setTotal(dto.getTotal());
        p.setFecha(dto.getFecha());
        return p;
    }
}
