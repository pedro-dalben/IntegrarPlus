# Regras do Projeto (Frontend/UX)

- Componentização: sempre usar `ViewComponent` para UI reutilizável.
- JS: usar Stimulus para interações (sem Alpine). Um controller por responsabilidade.
- **Stimulus obrigatório**: toda interação JavaScript deve usar Stimulus controllers.
- CSS: Tailwind v4 + tokens (`--t-*`, `--color-*`). Evitar utilitários custom fora de `application.css`/`tailadmin.css`.
- Acessibilidade: `aria-*`, foco visível, navegação por teclado, Esc para fechar overlays.
- Performance: importar libs JS sob demanda; inicializar via data-attributes.
- Documentação: todo componente/fluxo deve ter seção em `docs/`.
- Navegação: itens via `AdminNav` e guardados por `permit?`.
