import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';
import { Pedido } from '../../models/models';

/**
 * Orders CRUD view.
 */
@Component({
  selector: 'app-pedidos',
  template: `
    <div class="container">
      <div class="card">
        <h2>{{ editing ? 'Editar' : 'Nuevo' }} pedido</h2>
        <form (ngSubmit)="save()">
          <label>Cliente ID</label>
          <input type="number" [(ngModel)]="form.clienteId" name="clienteId" required />
          <label>Productos</label>
          <input [(ngModel)]="form.productos" name="productos" required />
          <label>Estado</label>
          <select [(ngModel)]="form.estado" name="estado">
            <option value="PENDIENTE">PENDIENTE</option>
            <option value="ENVIADO">ENVIADO</option>
            <option value="ENTREGADO">ENTREGADO</option>
            <option value="CANCELADO">CANCELADO</option>
          </select>
          <label>Total</label>
          <input type="number" [(ngModel)]="form.total" name="total" required />
          <button class="btn-primary" type="submit">{{ editing ? 'Actualizar' : 'Crear' }}</button>
          <button class="btn-secondary" type="button" *ngIf="editing" (click)="reset()">Cancelar</button>
        </form>
      </div>

      <div class="card">
        <h2>Pedidos</h2>
        <p *ngIf="error" style="color:#e11d48;">{{ error }}</p>
        <table>
          <thead>
            <tr><th>ID</th><th>Cliente</th><th>Productos</th><th>Estado</th><th>Total</th><th>Fecha</th><th></th></tr>
          </thead>
          <tbody>
            <tr *ngFor="let p of items">
              <td>{{ p.id }}</td>
              <td>{{ p.clienteId }}</td>
              <td>{{ p.productos }}</td>
              <td><span class="badge">{{ p.estado }}</span></td>
              <td>{{ p.total | number }}</td>
              <td>{{ p.fecha | date:'short' }}</td>
              <td class="row-actions">
                <button class="btn-secondary" (click)="edit(p)">Editar</button>
                <button class="btn-danger" (click)="remove(p)">Eliminar</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  `
})
export class PedidosComponent implements OnInit {
  items: Pedido[] = [];
  form: Pedido = this.empty();
  editing = false;
  error = '';

  constructor(private api: ApiService) {}

  ngOnInit(): void { this.load(); }

  load(): void {
    this.api.getPedidos().subscribe({
      next: (d) => this.items = d,
      error: () => this.error = 'Error al cargar pedidos.'
    });
  }

  save(): void {
    const req = this.editing && this.form.id
      ? this.api.updatePedido(this.form.id, this.form)
      : this.api.createPedido(this.form);
    req.subscribe({ next: () => { this.reset(); this.load(); },
      error: () => this.error = 'Error al guardar el pedido.' });
  }

  edit(p: Pedido): void { this.form = { ...p }; this.editing = true; }

  remove(p: Pedido): void {
    if (!p.id) { return; }
    this.api.deletePedido(p.id).subscribe({ next: () => this.load(),
      error: () => this.error = 'Error al eliminar.' });
  }

  reset(): void { this.form = this.empty(); this.editing = false; }

  private empty(): Pedido {
    return { clienteId: 0, productos: '', estado: 'PENDIENTE', total: 0 };
  }
}
