import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';
import { Producto } from '../../models/models';

/**
 * Products CRUD view.
 */
@Component({
  selector: 'app-productos',
  template: `
    <div class="container">
      <div class="card">
        <h2>{{ editing ? 'Editar' : 'Nuevo' }} producto</h2>
        <form (ngSubmit)="save()">
          <label>Nombre</label>
          <input [(ngModel)]="form.nombre" name="nombre" required />
          <label>Precio</label>
          <input type="number" [(ngModel)]="form.precio" name="precio" required />
          <label>Stock</label>
          <input type="number" [(ngModel)]="form.stock" name="stock" required />
          <label>Categoría</label>
          <input [(ngModel)]="form.categoria" name="categoria" required />
          <button class="btn-primary" type="submit">{{ editing ? 'Actualizar' : 'Crear' }}</button>
          <button class="btn-secondary" type="button" *ngIf="editing" (click)="reset()">Cancelar</button>
        </form>
      </div>

      <div class="card">
        <h2>Productos</h2>
        <p *ngIf="error" style="color:#e11d48;">{{ error }}</p>
        <table>
          <thead>
            <tr><th>ID</th><th>Nombre</th><th>Precio</th><th>Stock</th><th>Categoría</th><th></th></tr>
          </thead>
          <tbody>
            <tr *ngFor="let p of items">
              <td>{{ p.id }}</td>
              <td>{{ p.nombre }}</td>
              <td>{{ p.precio | number }}</td>
              <td>{{ p.stock }}</td>
              <td><span class="badge">{{ p.categoria }}</span></td>
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
export class ProductosComponent implements OnInit {
  items: Producto[] = [];
  form: Producto = this.empty();
  editing = false;
  error = '';

  constructor(private api: ApiService) {}

  ngOnInit(): void { this.load(); }

  load(): void {
    this.api.getProductos().subscribe({
      next: (d) => this.items = d,
      error: () => this.error = 'Error al cargar productos.'
    });
  }

  save(): void {
    const req = this.editing && this.form.id
      ? this.api.updateProducto(this.form.id, this.form)
      : this.api.createProducto(this.form);
    req.subscribe({ next: () => { this.reset(); this.load(); },
      error: () => this.error = 'Error al guardar el producto.' });
  }

  edit(p: Producto): void { this.form = { ...p }; this.editing = true; }

  remove(p: Producto): void {
    if (!p.id) { return; }
    this.api.deleteProducto(p.id).subscribe({ next: () => this.load(),
      error: () => this.error = 'Error al eliminar.' });
  }

  reset(): void { this.form = this.empty(); this.editing = false; }

  private empty(): Producto {
    return { nombre: '', precio: 0, stock: 0, categoria: '' };
  }
}
