# UX Guidelines do Layout Admin

Topbar

- Logo, botão de menu (mobile), toggle de tema, menu de usuário.
- Altura 56px.

Sidebar

- Colapsável no desktop; off-canvas no mobile com overlay.
- Foco visível nos itens, labels ocultáveis no estado colapsado.

Breadcrumbs e Slots

- `Layouts::AdminComponent` aceita `title:` e slot `actions`.
- Breadcrumbs opcionais via array de hashes `{ label:, path: }`.

Espaçamento e Grid

- Container: `container-app`.
- Espaçamentos base: tokens do Tailwind v4.
- Alvos de toque mínimos ~44x44px.


