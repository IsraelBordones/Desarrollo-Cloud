package com.pedidos360.productos.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.pedidos360.productos.model.Producto;

@Repository
public interface ProductoRepository extends JpaRepository<Producto, Long> {
}
