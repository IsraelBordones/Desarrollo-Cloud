import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { MsalGuard } from '@azure/msal-angular';

import { LoginComponent } from './components/login/login.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { PedidosComponent } from './components/pedidos/pedidos.component';
import { ProductosComponent } from './components/productos/productos.component';
import { ClientesComponent } from './components/clientes/clientes.component';

/**
 * Routes. Everything except /login is protected by MsalGuard, which triggers
 * the Azure AD login flow when no valid session/token exists.
 */
const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: '', component: DashboardComponent, canActivate: [MsalGuard] },
  { path: 'pedidos', component: PedidosComponent, canActivate: [MsalGuard] },
  { path: 'productos', component: ProductosComponent, canActivate: [MsalGuard] },
  { path: 'clientes', component: ClientesComponent, canActivate: [MsalGuard] },
  { path: '**', redirectTo: '' }
];

@NgModule({
  // Hash routing avoids MSAL redirect conflicts on static hosting (S3/CloudFront)
  imports: [RouterModule.forRoot(routes, { initialNavigation: 'enabledNonBlocking' })],
  exports: [RouterModule]
})
export class AppRoutingModule {}
