# IntegrarPlus — Guia de UI/UX e Layout

- Stack: Rails 8 + Vite + Tailwind v4 + ViewComponent + Stimulus.
- Tema: baseado no TailAdmin (Tailwind), portado para componentes e controllers Stimulus.

## Componentes de Layout
- `Layouts::TopbarComponent`: topbar com breadcrumbs, título, busca e avatar.
- `Layouts::SidebarComponent`: sidebar com seções, itens via `AdminNav` e off-canvas mobile.
- `Layouts::AuthComponent`: layout de autenticação (login/registro).

## Controllers Stimulus
- `menu`: abre/fecha dropdowns (aria-expanded, clique-fora recomendado quando necessário).
- `sidebar`: off-canvas mobile (overlay, Esc, foco inicial).
- `chart`: inicialização de gráficos (Chart.js) por data-attributes.
- `datepicker`: inicialização de flatpickr via data-attributes.

## Páginas
- Login: `devise/sessions/new.html.erb`.
- Dashboard: cards, gráfico e tabela — base para evoluir.

## Boas práticas
- Estilização com tokens (`--t-*`, `--color-*`) e utilitários Tailwind v4.
- Componentizar com ViewComponent; JS com Stimulus.
- Instalar libs por demanda e inicializar via controllers.
