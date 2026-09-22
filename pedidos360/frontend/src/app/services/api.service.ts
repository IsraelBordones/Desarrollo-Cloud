import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { Pedido, Producto, Cliente, Notificacion } from '../models/models';

/**
 * Central API service. All calls target the AWS API Gateway (or local BFF).
 * The MsalInterceptor automatically attaches the Azure AD bearer token, so no
 * manual Authorization handling is needed here.
 */
@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly base = environment.apiGatewayUrl;

  constructor(private http: HttpClient) {}

  // ---- Pedidos ----
  getPedidos(): Observable<Pedido[]> {
    return this.http.get<Pedido[]>(`${this.base}/pedidos`);
  }
  createPedido(p: Pedido): Observable<Pedido> {
    return this.http.post<Pedido>(`${this.base}/pedidos`, p);
  }
  updatePedido(id: number, p: Pedido): Observable<Pedido> {
    return this.http.put<Pedido>(`${this.base}/pedidos/${id}`, p);
  }
  deletePedido(id: number): Observable<void> {
    return this.http.delete<void>(`${this.base}/pedidos/${id}`);
  }

  // ---- Productos ----
  getProductos(): Observable<Producto[]> {
    return this.http.get<Producto[]>(`${this.base}/productos`);
  }
  createProducto(p: Producto): Observable<Producto> {
    return this.http.post<Producto>(`${this.base}/productos`, p);
  }
  updateProducto(id: number, p: Producto): Observable<Producto> {
    return this.http.put<Producto>(`${this.base}/productos/${id}`, p);
  }
  deleteProducto(id: number): Observable<void> {
    return this.http.delete<void>(`${this.base}/productos/${id}`);
  }

  // ---- Clientes ----
  getClientes(): Observable<Cliente[]> {
    return this.http.get<Cliente[]>(`${this.base}/clientes`);
  }
  createCliente(c: Cliente): Observable<Cliente> {
    return this.http.post<Cliente>(`${this.base}/clientes`, c);
  }
  updateCliente(id: number, c: Cliente): Observable<Cliente> {
    return this.http.put<Cliente>(`${this.base}/clientes/${id}`, c);
  }
  deleteCliente(id: number): Observable<void> {
    return this.http.delete<void>(`${this.base}/clientes/${id}`);
  }

  // ---- Notificaciones ----
  getNotificaciones(): Observable<Notificacion[]> {
    return this.http.get<Notificacion[]>(`${this.base}/notificaciones/history`);
  }
  notify(n: Notificacion): Observable<Notificacion> {
    return this.http.post<Notificacion>(`${this.base}/notificaciones/notify`, n);
  }
}
