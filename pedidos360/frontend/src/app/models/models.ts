export interface Pedido {
  id?: number;
  clienteId: number;
  productos: string;
  estado?: string;
  total: number;
  fecha?: string;
}

export interface Producto {
  id?: number;
  nombre: string;
  precio: number;
  stock: number;
  categoria: string;
}

export interface Cliente {
  id?: number;
  nombre: string;
  email: string;
  telefono?: string;
  direccion?: string;
}

export interface Notificacion {
  id?: number;
  pedidoId: number;
  mensaje: string;
  canal?: string;
  estado?: string;
  fecha?: string;
}
