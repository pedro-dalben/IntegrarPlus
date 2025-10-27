# Sentry - Monitoramento de Erros

## Visão Geral

O Sentry está configurado no projeto para monitorar e rastrear erros em produção, permitindo identificar e corrigir problemas rapidamente.

## Instalação

As gems necessárias já estão instaladas:

```ruby
gem 'sentry-ruby'
gem 'sentry-rails'
```

## Configuração

### Arquivo de Configuração

O Sentry está configurado em `config/initializers/sentry.rb`:

- **DSN**: Configurado via variável de ambiente `SENTRY_DSN` com fallback para o DSN do projeto
- **Breadcrumbs**: Registra logs do Active Support e requisições HTTP
- **PII (Personal Identifiable Information)**: Habilitado para incluir dados como headers de requisição e IP dos usuários
- **Sample Rate**: 25% em produção, 100% em desenvolvimento
- **Ambientes Habilitados**: Apenas produção e staging
- **Exceções Excluídas**: Erros de roteamento (404) e registros não encontrados

### Variáveis de Ambiente

Adicione ao arquivo `.env` (ou configure no servidor):

```bash
SENTRY_DSN=https://e2d43c8f49a711ef9088f132e16d6b2a@o4510263217618944.ingest.us.sentry.io/4510263219126272
```

### Layout da Aplicação

O gerador do Sentry adicionou automaticamente a meta tag de rastreamento no layout:

```erb
<%= Sentry.get_trace_propagation_meta.html_safe %>
```

Esta tag permite rastrear requisições entre diferentes serviços e melhorar a depuração.

## Uso

### Capturar Exceções Manualmente

```ruby
begin
  # código que pode gerar erro
rescue StandardError => e
  Sentry.capture_exception(e)
end
```

### Enviar Mensagens

```ruby
Sentry.capture_message("Algo importante aconteceu")
```

### Adicionar Contexto

```ruby
Sentry.set_user(id: current_user.id, email: current_user.email)
Sentry.set_context("business", { company_id: company.id, plan: company.plan })
```

### Adicionar Tags

```ruby
Sentry.set_tags(feature: "import", batch_size: 100)
```

### Adicionar Breadcrumbs

```ruby
Sentry.add_breadcrumb(
  category: "auth",
  message: "User logged in",
  level: "info"
)
```

## Teste

Para testar se o Sentry está funcionando, execute no console Rails:

```ruby
# Gerar um erro
begin
  1 / 0
rescue ZeroDivisionError => exception
  Sentry.capture_exception(exception)
end

# Enviar mensagem de teste
Sentry.capture_message("test message")
```

Após executar, verifique o dashboard do Sentry em:
https://sentry.io/

## Recursos Capturados Automaticamente

O Sentry Rails captura automaticamente:

- ✅ Exceções não tratadas em controllers
- ✅ Erros em jobs do Active Job
- ✅ Erros em background jobs (Sidekiq, etc)
- ✅ Request headers
- ✅ IP do usuário
- ✅ Dados da requisição (params, cookies, session)
- ✅ Stack trace completo
- ✅ Logs e breadcrumbs

## Exceções Excluídas

As seguintes exceções não são enviadas ao Sentry (configuradas como ruído):

- `ActionController::RoutingError` - Páginas não encontradas (404)
- `ActiveRecord::RecordNotFound` - Registros não encontrados

## Performance Monitoring

O Sentry está configurado com traces_sample_rate:

- **Produção**: 25% das requisições são rastreadas
- **Desenvolvimento**: 100% das requisições são rastreadas

Isso permite monitorar o desempenho da aplicação sem sobrecarregar o Sentry.

## Ambientes

O Sentry está habilitado apenas para:

- **production**
- **staging**

Em desenvolvimento e teste, o Sentry não enviará dados (mas continuará funcionando localmente para testes).

## Dashboard Sentry

Acesse o dashboard em: https://sentry.io/

Lá você pode:

- Ver todos os erros em tempo real
- Analisar stack traces
- Ver breadcrumbs e contexto de cada erro
- Agrupar erros similares
- Marcar erros como resolvidos
- Configurar alertas por email/Slack
- Ver gráficos de performance

## Melhores Práticas

1. **Use contexto**: Sempre adicione contexto relevante aos erros
2. **Adicione usuário**: Use `Sentry.set_user` para identificar quem foi afetado
3. **Tags significativas**: Use tags para facilitar a busca e filtros
4. **Resolva erros**: Marque erros como resolvidos no dashboard
5. **Monitore releases**: Configure releases no Sentry para rastrear quando bugs foram introduzidos
6. **Configurar alertas**: Configure notificações para erros críticos

## Deploy

Ao fazer deploy em produção via Kamal:

1. Certifique-se de que a variável `SENTRY_DSN` está configurada no `.env` do servidor
2. O Sentry começará a capturar erros automaticamente
3. Acesse o dashboard para verificar

## Integração com CI/CD

Para releases, você pode notificar o Sentry sobre deploys:

```bash
# Criar um release no Sentry
sentry-cli releases new "v1.0.0"
sentry-cli releases set-commits "v1.0.0" --auto
sentry-cli releases finalize "v1.0.0"
```

## Links Úteis

- [Documentação Sentry Ruby](https://docs.sentry.io/platforms/ruby/)
- [Documentação Sentry Rails](https://docs.sentry.io/platforms/ruby/guides/rails/)
- [Dashboard Sentry](https://sentry.io/)
