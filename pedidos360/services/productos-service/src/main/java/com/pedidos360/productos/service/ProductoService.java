package com.pedidos360.productos.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.pedidos360.productos.dto.ProductoDTO;
import com.pedidos360.productos.model.Producto;
import com.pedidos360.productos.repository.ProductoRepository;

/**
 * Business logic for products.
 */
@Service
public class ProductoService {

    private final ProductoRepository repository;

    public ProductoService(ProductoRepository repository) {
        this.repository = repository;
    }

    public List<ProductoDTO> findAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    public ProductoDTO findById(Long id) {
        return toDto(repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Producto " + id + " not found")));
    }

    public ProductoDTO create(ProductoDTO dto) {
        Producto entity = toEntity(dto);
        entity.setId(null);
        return toDto(repository.save(entity));
    }

    public ProductoDTO update(Long id, ProductoDTO dto) {
        Producto entity = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Producto " + id + " not found"));
        entity.setNombre(dto.getNombre());
        entity.setPrecio(dto.getPrecio());
        entity.setStock(dto.getStock());
        entity.setCategoria(dto.getCategoria());
        return toDto(repository.save(entity));
    }

    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Producto " + id + " not found");
        }
        repository.deleteById(id);
    }

    private ProductoDTO toDto(Producto p) {
        ProductoDTO dto = new ProductoDTO();
        dto.setId(p.getId());
        dto.setNombre(p.getNombre());
        dto.setPrecio(p.getPrecio());
        dto.setStock(p.getStock());
        dto.setCategoria(p.getCategoria());
        return dto;
    }

    private Producto toEntity(ProductoDTO dto) {
        Producto p = new Producto();
        p.setId(dto.getId());
        p.setNombre(dto.getNombre());
        p.setPrecio(dto.getPrecio());
        p.setStock(dto.getStock());
        p.setCategoria(dto.getCategoria());
        return p;
    }
}
