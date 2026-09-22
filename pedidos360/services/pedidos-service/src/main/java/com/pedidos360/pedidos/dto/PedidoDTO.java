package com.pedidos360.pedidos.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

/**
 * Data transfer object for orders.
 */
public class PedidoDTO {

    private Long id;

    @NotNull(message = "clienteId is required")
    private Long clienteId;

    @NotBlank(message = "productos is required")
    private String productos;

    private String estado;

    @NotNull(message = "total is required")
    @PositiveOrZero(message = "total must be >= 0")
    private BigDecimal total;

    private LocalDateTime fecha;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getClienteId() { return clienteId; }
    public void setClienteId(Long clienteId) { this.clienteId = clienteId; }
    public String getProductos() { return productos; }
    public void setProductos(String productos) { this.productos = productos; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }
    public LocalDateTime getFecha() { return fecha; }
    public void setFecha(LocalDateTime fecha) { this.fecha = fecha; }
}
