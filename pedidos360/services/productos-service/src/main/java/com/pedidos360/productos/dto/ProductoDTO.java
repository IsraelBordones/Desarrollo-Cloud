package com.pedidos360.productos.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

/**
 * Data transfer object for products.
 */
public class ProductoDTO {

    private Long id;

    @NotBlank(message = "nombre is required")
    private String nombre;

    @NotNull(message = "precio is required")
    @PositiveOrZero(message = "precio must be >= 0")
    private BigDecimal precio;

    @NotNull(message = "stock is required")
    @PositiveOrZero(message = "stock must be >= 0")
    private Integer stock;

    @NotBlank(message = "categoria is required")
    private String categoria;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public BigDecimal getPrecio() { return precio; }
    public void setPrecio(BigDecimal precio) { this.precio = precio; }
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }
}
