# Layout Admin (IntegrarPlus)

Objetivo e escopo

- Layout base para área administrativa com Topbar, Sidebar, slots de título/ações e suporte a dark mode.
- Responsivo (mobile-first) usando tokens do T1 e utilitários Tailwind.

Estrutura

- Componentes: `Layouts::AdminComponent`, `Layouts::TopbarComponent`, `Layouts::SidebarComponent`.
- Navegação: `app/navigation/admin_nav.rb`.
- Controllers: `Admin::BaseController`, `Admin::DashboardController`, `Admin::UiController`.
- Views: `app/views/admin/dashboard/index.html.erb`, `app/views/admin/ui/index.html.erb`.

Decisões

- Sidebar única fonte de navegação via `AdminNav.items` com chave `required_permission`.
- Dark mode via classe `dark` na raiz; toggle conectado a controller Stimulus `theme`.
- Acessibilidade com `role="navigation"`, `aria-label`, foco visível e off-canvas no mobile.


