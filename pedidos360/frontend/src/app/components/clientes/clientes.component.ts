import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';
import { Cliente } from '../../models/models';

/**
 * Customers CRUD view.
 */
@Component({
  selector: 'app-clientes',
  template: `
    <div class="container">
      <div class="card">
        <h2>{{ editing ? 'Editar' : 'Nuevo' }} cliente</h2>
        <form (ngSubmit)="save()">
          <label>Nombre</label>
          <input [(ngModel)]="form.nombre" name="nombre" required />
          <label>Email</label>
          <input type="email" [(ngModel)]="form.email" name="email" required />
          <label>Teléfono</label>
          <input [(ngModel)]="form.telefono" name="telefono" />
          <label>Dirección</label>
          <input [(ngModel)]="form.direccion" name="direccion" />
          <button class="btn-primary" type="submit">{{ editing ? 'Actualizar' : 'Crear' }}</button>
          <button class="btn-secondary" type="button" *ngIf="editing" (click)="reset()">Cancelar</button>
        </form>
      </div>

      <div class="card">
        <h2>Clientes</h2>
        <p *ngIf="error" style="color:#e11d48;">{{ error }}</p>
        <table>
          <thead>
            <tr><th>ID</th><th>Nombre</th><th>Email</th><th>Teléfono</th><th>Dirección</th><th></th></tr>
          </thead>
          <tbody>
            <tr *ngFor="let c of items">
              <td>{{ c.id }}</td>
              <td>{{ c.nombre }}</td>
              <td>{{ c.email }}</td>
              <td>{{ c.telefono }}</td>
              <td>{{ c.direccion }}</td>
              <td class="row-actions">
                <button class="btn-secondary" (click)="edit(c)">Editar</button>
                <button class="btn-danger" (click)="remove(c)">Eliminar</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  `
})
export class ClientesComponent implements OnInit {
  items: Cliente[] = [];
  form: Cliente = this.empty();
  editing = false;
  error = '';

  constructor(private api: ApiService) {}

  ngOnInit(): void { this.load(); }

  load(): void {
    this.api.getClientes().subscribe({
      next: (d) => this.items = d,
      error: () => this.error = 'Error al cargar clientes.'
    });
  }

  save(): void {
    const req = this.editing && this.form.id
      ? this.api.updateCliente(this.form.id, this.form)
      : this.api.createCliente(this.form);
    req.subscribe({ next: () => { this.reset(); this.load(); },
      error: () => this.error = 'Error al guardar el cliente.' });
  }

  edit(c: Cliente): void { this.form = { ...c }; this.editing = true; }

  remove(c: Cliente): void {
    if (!c.id) { return; }
    this.api.deleteCliente(c.id).subscribe({ next: () => this.load(),
      error: () => this.error = 'Error al eliminar.' });
  }

  reset(): void { this.form = this.empty(); this.editing = false; }

  private empty(): Cliente {
    return { nombre: '', email: '', telefono: '', direccion: '' };
  }
}
