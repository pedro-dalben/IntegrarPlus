# IntegrarPlus

Stack: Rails 8, Vite, Tailwind v4, Hotwire (Turbo/Stimulus), Devise, Pundit, Solid Queue/Cache/Cable, Active Storage, PaperTrail.

Requisitos
- Ruby e Bundler
- Node.js e Yarn
- PostgreSQL

Setup
1. bundle install
2. yarn install
3. bin/rails db:prepare
4. bin/vite build

Dev
- bin/dev (usa Foreman) ou:
  - bin/rails s
  - bin/vite dev

Gems instaladas
- Autenticação: Devise
- Autorização: Pundit
- Jobs/Filas: Solid Queue (Active Job default)
- Storage: Active Storage + image_processing
- Versionamento: PaperTrail
- Front-end: Vite + Tailwind v4 + Preline + Turbo/Stimulus
- Formulários: Simple Form (+ @tailwindcss/forms)
- Monitoramento: Sentry (rastreamento de erros e performance)

Monitoramento
- Sentry configurado para produção e staging
- Configure SENTRY_DSN no .env para habilitar
- Execute bin/test-sentry para testar a integração
- Documentação: docs/SENTRY_MONITORAMENTO.md

Observações
- Ajustar credenciais e variáveis em .env conforme necessário.
