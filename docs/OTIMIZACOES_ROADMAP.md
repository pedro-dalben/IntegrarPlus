# 🚀 Roadmap de Otimizações - IntegrarPlus

**Data**: 28 de Outubro de 2025
**Status**: 📋 Planejamento

---

## 📊 Análise do Estado Atual

### ✅ Pontos Fortes Já Implementados
- ✅ **Turbo/Hotwire**: Navegação SPA-like implementada
- ✅ **Vite**: Build tool moderno configurado
- ✅ **Stimulus**: Controllers organizados
- ✅ **ViewComponents**: Componentização Ruby
- ✅ **TailwindCSS**: Estilização otimizada
- ✅ **MeiliSearch**: Busca rápida configurada
- ✅ **Solid Queue**: Jobs em background

### 🎯 Oportunidades de Melhoria Identificadas

#### Performance
- ⚠️ **N+1 Queries**: Possíveis queries não otimizadas
- ⚠️ **Asset Loading**: Sem estratégia de preload/prefetch
- ⚠️ **Image Optimization**: Imagens sem otimização
- ⚠️ **Cache Strategy**: Cache não implementado sistematicamente
- ⚠️ **Bundle Size**: Sem code splitting avançado

#### UX/Loading
- ⚠️ **Loading States**: Poucos indicators de carregamento
- ⚠️ **Skeleton Screens**: Não implementados
- ⚠️ **Lazy Loading**: Imagens sem lazy load
- ⚠️ **Offline Support**: PWA básico, pode melhorar
- ⚠️ **Error Boundaries**: Tratamento de erros pode melhorar

#### Developer Experience
- ⚠️ **Monitoring**: Sem APM configurado
- ⚠️ **Error Tracking**: Sentry configurado mas pode melhorar
- ⚠️ **Performance Metrics**: Sem Web Vitals tracking
- ⚠️ **CI/CD**: GitHub Actions básico

---

## 🎯 Roadmap de Otimizações

### 🔴 Prioridade CRÍTICA (Impacto Alto, Esforço Baixo)

#### 1. Implementar Loading States Globais
**Problema**: Usuários não sabem quando algo está carregando
**Solução**: Loading indicators consistentes

**Implementação**:
```javascript
// app/frontend/javascript/controllers/loading_controller.js
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['spinner', 'content'];

  connect() {
    this.showLoading();

    // Turbo events
    document.addEventListener('turbo:before-fetch-request', this.showLoading.bind(this));
    document.addEventListener('turbo:before-fetch-response', this.hideLoading.bind(this));
  }

  showLoading() {
    if (this.hasSpinnerTarget) this.spinnerTarget.classList.remove('hidden');
    if (this.hasContentTarget) this.contentTarget.classList.add('opacity-50');
  }

  hideLoading() {
    if (this.hasSpinnerTarget) this.spinnerTarget.classList.add('hidden');
    if (this.hasContentTarget) this.contentTarget.classList.remove('opacity-50');
  }
}
```

**Impacto**: 📈 +30% em perceived performance
**Esforço**: 🕐 2-4 horas
**ROI**: ⭐⭐⭐⭐⭐

---

#### 2. Otimizar Queries com Bullet Gem
**Problema**: N+1 queries degradando performance

**Implementação**:
```ruby
# Gemfile
gem 'bullet', group: :development

# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
end
```

**Ações**:
1. Identificar N+1 queries com Bullet
2. Adicionar `includes`/`eager_load` onde necessário
3. Adicionar índices no banco de dados
4. Usar `select` para buscar apenas campos necessários

**Exemplo de Otimização**:
```ruby
# ❌ ANTES (N+1)
@beneficiaries = Beneficiary.all
# View: @beneficiaries.each { |b| b.anamnesis.nome }

# ✅ DEPOIS
@beneficiaries = Beneficiary.includes(:anamnesis).all
```

**Impacto**: 📈 -50% em tempo de resposta
**Esforço**: 🕐 4-8 horas
**ROI**: ⭐⭐⭐⭐⭐

---

#### 3. Implementar Russian Doll Caching
**Problema**: Views são renderizadas repetidamente

**Implementação**:
```ruby
# app/views/admin/beneficiaries/_beneficiary.html.erb
<% cache beneficiary do %>
  <div class="beneficiary-card">
    <%= beneficiary.nome %>

    <% cache [beneficiary, :anamnesis] do %>
      <%= render beneficiary.anamnesis %>
    <% end %>
  </div>
<% end %>
```

**Configuração**:
```ruby
# config/environments/production.rb
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  expires_in: 90.minutes
}
```

**Impacto**: 📈 -60% em tempo de renderização
**Esforço**: 🕐 6-12 horas
**ROI**: ⭐⭐⭐⭐⭐

---

### 🟠 Prioridade ALTA (Impacto Alto, Esforço Médio)

#### 4. Implementar Lazy Loading de Imagens
**Problema**: Todas as imagens carregam imediatamente

**Implementação**:
```ruby
# app/helpers/image_helper.rb
module ImageHelper
  def lazy_image_tag(source, options = {})
    options[:loading] = 'lazy'
    options[:decoding] = 'async'
    options[:class] = "#{options[:class]} lazy-image"

    image_tag(source, options)
  end
end
```

**Controller Stimulus para Progressive Loading**:
```javascript
// app/frontend/javascript/controllers/lazy_image_controller.js
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = { src: String, placeholder: String };

  connect() {
    if ('IntersectionObserver' in window) {
      this.observer = new IntersectionObserver(this.loadImage.bind(this));
      this.observer.observe(this.element);
    } else {
      this.loadImage();
    }
  }

  disconnect() {
    if (this.observer) this.observer.disconnect();
  }

  loadImage(entries) {
    if (!entries || entries[0].isIntersecting) {
      const img = new Image();
      img.src = this.srcValue;
      img.onload = () => {
        this.element.src = this.srcValue;
        this.element.classList.add('loaded');
      };
    }
  }
}
```

**Impacto**: 📈 -40% em tempo de carregamento inicial
**Esforço**: 🕐 4-6 horas
**ROI**: ⭐⭐⭐⭐

---

#### 5. Skeleton Screens para Melhor UX
**Problema**: Telas vazias durante carregamento

**Implementação**:
```ruby
# app/components/skeleton_component.rb
class SkeletonComponent < ViewComponent::Base
  def initialize(type: :card, count: 1)
    @type = type
    @count = count
  end
end
```

```erb
<!-- app/components/skeleton_component.html.erb -->
<div class="animate-pulse space-y-4">
  <% @count.times do %>
    <%= render "skeleton_#{@type}" %>
  <% end %>
</div>

<!-- _skeleton_card.html.erb -->
<div class="bg-gray-200 dark:bg-gray-700 rounded-lg p-4">
  <div class="h-4 bg-gray-300 dark:bg-gray-600 rounded w-3/4 mb-2"></div>
  <div class="h-3 bg-gray-300 dark:bg-gray-600 rounded w-1/2"></div>
</div>
```

**Uso com Turbo Frames**:
```erb
<%= turbo_frame_tag "beneficiaries", loading: :lazy do %>
  <%= render SkeletonComponent.new(type: :card, count: 5) %>
<% end %>
```

**Impacto**: 📈 +40% em perceived performance
**Esforço**: 🕐 8-12 horas
**ROI**: ⭐⭐⭐⭐

---

#### 6. Implementar Code Splitting e Preloading
**Problema**: Bundle JavaScript muito grande

**Implementação**:
```javascript
// vite.config.mts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['@hotwired/stimulus', '@hotwired/turbo-rails'],
          'calendar': ['@fullcalendar/core'],
          'charts': ['apexcharts'],
          'forms': ['tom-select'],
        }
      }
    }
  }
});
```

**Preload Critical Resources**:
```erb
<!-- app/views/layouts/application.html.erb -->
<%= vite_javascript_tag 'application',
    'data-turbo-track': 'reload',
    crossorigin: 'anonymous',
    async: true %>

<link rel="preload" href="<%= asset_path('tailadmin-pro.css') %>" as="style">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="dns-prefetch" href="<%= ENV['CDN_URL'] %>">
```

**Impacto**: 📈 -30% em bundle size
**Esforço**: 🕐 6-10 horas
**ROI**: ⭐⭐⭐⭐

---

### 🟡 Prioridade MÉDIA (Impacto Médio, Esforço Médio)

#### 7. Implementar Service Worker Avançado
**Problema**: PWA básico sem cache estratégico

**Implementação**:
```javascript
// public/service-worker.js
const CACHE_VERSION = 'v1';
const CACHE_STATIC = `static-${CACHE_VERSION}`;
const CACHE_DYNAMIC = `dynamic-${CACHE_VERSION}`;
const CACHE_IMAGES = `images-${CACHE_VERSION}`;

// Cache Strategy: Cache First
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Images: Cache First
  if (request.destination === 'image') {
    event.respondWith(cacheFirst(request, CACHE_IMAGES));
  }
  // Static Assets: Cache First
  else if (url.pathname.match(/\.(css|js|woff2)$/)) {
    event.respondWith(cacheFirst(request, CACHE_STATIC));
  }
  // API/HTML: Network First
  else {
    event.respondWith(networkFirst(request, CACHE_DYNAMIC));
  }
});

async function cacheFirst(request, cacheName) {
  const cached = await caches.match(request);
  if (cached) return cached;

  const response = await fetch(request);
  const cache = await caches.open(cacheName);
  cache.put(request, response.clone());
  return response;
}

async function networkFirst(request, cacheName) {
  try {
    const response = await fetch(request);
    const cache = await caches.open(cacheName);
    cache.put(request, response.clone());
    return response;
  } catch (error) {
    const cached = await caches.match(request);
    return cached || new Response('Offline');
  }
}
```

**Impacto**: 📈 +50% em performance offline
**Esforço**: 🕐 8-12 horas
**ROI**: ⭐⭐⭐

---

#### 8. Implementar Database Connection Pooling
**Problema**: Conexões DB não otimizadas

**Implementação**:
```ruby
# config/database.yml
production:
  pool: <%= ENV.fetch("DB_POOL") { 25 } %>
  timeout: 5000
  checkout_timeout: 5
  reaping_frequency: 10

  # PgBouncer configuration
  prepared_statements: false
  advisory_locks: false
```

**PgBouncer Setup**:
```ini
# /etc/pgbouncer/pgbouncer.ini
[databases]
integrarplus = host=localhost port=5432 dbname=integrarplus_production

[pgbouncer]
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 25
reserve_pool_size = 5
reserve_pool_timeout = 3
```

**Impacto**: 📈 +100% em concurrent connections
**Esforço**: 🕐 4-6 horas
**ROI**: ⭐⭐⭐⭐

---

#### 9. Implementar Background Jobs para Operações Pesadas
**Problema**: Operações síncronas bloqueiam requests

**Já tem Solid Queue, mas precisa usar mais**:
```ruby
# app/jobs/anamnesis_pdf_generator_job.rb
class AnamnesisPdfGeneratorJob < ApplicationJob
  queue_as :default

  def perform(anamnesis_id)
    anamnesis = Anamnesis.find(anamnesis_id)
    pdf = AnamnesisPdfService.new(anamnesis).generate

    anamnesis.update(pdf_url: upload_to_storage(pdf))

    # Broadcast via Turbo Stream
    Turbo::StreamsChannel.broadcast_update_to(
      "anamnesis_#{anamnesis.id}",
      target: "anamnesis-pdf",
      partial: "anamneses/pdf_ready",
      locals: { anamnesis: anamnesis }
    )
  end
end

# Controller
def generate_pdf
  AnamnesisPdfGeneratorJob.perform_later(@anamnesis.id)

  respond_to do |format|
    format.turbo_stream {
      render turbo_stream: turbo_stream.update(
        "anamnesis-pdf",
        partial: "anamneses/pdf_generating"
      )
    }
  end
end
```

**Operações para Background**:
- Geração de PDFs
- Envio de emails
- Processamento de imagens
- Sincronização com MeiliSearch
- Limpeza de dados antigos

**Impacto**: 📈 -70% em tempo de resposta
**Esforço**: 🕐 12-16 horas
**ROI**: ⭐⭐⭐⭐

---

#### 10. Implementar HTTP/2 Server Push
**Problema**: Múltiplos round-trips para assets

**Nginx Configuration**:
```nginx
# /etc/nginx/sites-available/integrarplus
server {
    listen 443 ssl http2;
    server_name integrarplus.com;

    # HTTP/2 Server Push
    location = /admin {
        http2_push /assets/application.css;
        http2_push /assets/application.js;
        http2_push /assets/tailadmin-pro.css;

        proxy_pass http://rails_backend;
    }

    # Brotli Compression
    brotli on;
    brotli_comp_level 6;
    brotli_types text/plain text/css application/javascript;

    # Gzip fallback
    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css application/javascript;
}
```

**Impacto**: 📈 -20% em tempo de carregamento
**Esforço**: 🕐 4-6 horas
**ROI**: ⭐⭐⭐

---

### 🔵 Prioridade BAIXA (Impacto Médio, Esforço Alto)

#### 11. Implementar CDN para Assets Estáticos
**Problema**: Assets servidos do servidor principal

**Implementação com Cloudflare**:
```ruby
# config/environments/production.rb
config.asset_host = ENV['CDN_URL']
config.action_controller.asset_host = ENV['CDN_URL']
```

**CloudFlare Workers para Otimização**:
```javascript
// cloudflare-worker.js
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
  const cache = caches.default;
  let response = await cache.match(request);

  if (!response) {
    response = await fetch(request);

    // Cache images for 1 year
    if (request.url.match(/\.(jpg|jpeg|png|gif|webp)$/)) {
      response = new Response(response.body, response);
      response.headers.set('Cache-Control', 'public, max-age=31536000');
      event.waitUntil(cache.put(request, response.clone()));
    }
  }

  return response;
}
```

**Impacto**: 📈 -40% em latência global
**Esforço**: 🕐 8-12 horas
**ROI**: ⭐⭐⭐

---

#### 12. Implementar Monitoring e APM
**Problema**: Sem visibilidade de performance em produção

**Opções de APM**:
1. **New Relic** (Completo, pago)
2. **Scout APM** (Rails-focused, acessível)
3. **Skylight** (Rails-only, visual)

**Implementação Scout APM**:
```ruby
# Gemfile
gem 'scout_apm'

# config/scout_apm.yml
production:
  key: <%= ENV['SCOUT_KEY'] %>
  monitor: true
  name: IntegrarPlus Production

  # Custom Instruments
  instrument:
    - ActiveRecord
    - ActionController
    - ActionView
    - Redis
    - HTTP
```

**Custom Instrumentation**:
```ruby
# app/services/anamnesis_pdf_service.rb
class AnamnesisPdfService
  include ScoutApm::Tracer

  instrument_method :generate, type: 'PDF Generation'

  def generate
    # ... PDF logic
  end
end
```

**Impacto**: 📈 Visibilidade completa de performance
**Esforço**: 🕐 6-10 horas
**ROI**: ⭐⭐⭐⭐

---

#### 13. Implementar Web Vitals Tracking
**Problema**: Sem métricas de UX

**Implementação**:
```javascript
// app/frontend/javascript/web-vitals.js
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

function sendToAnalytics({ name, delta, value, id }) {
  fetch('/api/analytics/web-vitals', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name, delta, value, id })
  });
}

getCLS(sendToAnalytics);
getFID(sendToAnalytics);
getFCP(sendToAnalytics);
getLCP(sendToAnalytics);
getTTFB(sendToAnalytics);
```

**Dashboard Rails**:
```ruby
# app/controllers/analytics_controller.rb
class AnalyticsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :web_vitals

  def web_vitals
    WebVitalsMetric.create(
      name: params[:name],
      value: params[:value],
      page: request.referer
    )
    head :ok
  end

  def dashboard
    @metrics = WebVitalsMetric
      .where('created_at > ?', 7.days.ago)
      .group(:name)
      .average(:value)
  end
end
```

**Impacto**: 📈 Métricas de UX quantificáveis
**Esforço**: 🕐 10-14 horas
**ROI**: ⭐⭐⭐

---

## 📊 Resumo de Prioridades

### Quick Wins (Fazer AGORA)
1. ✅ Loading States Globais (2-4h) → +30% perceived perf
2. ✅ Otimizar Queries com Bullet (4-8h) → -50% response time
3. ✅ Russian Doll Caching (6-12h) → -60% render time

**Total Esforço**: 12-24 horas
**Impacto Combinado**: 📈 +120% em performance percebida

---

### High Impact (Fazer ESTA SEMANA)
4. ✅ Lazy Loading de Imagens (4-6h)
5. ✅ Skeleton Screens (8-12h)
6. ✅ Code Splitting (6-10h)

**Total Esforço**: 18-28 horas
**Impacto Combinado**: 📈 +110% em métricas objetivas

---

### Strategic (Fazer ESTE MÊS)
7. ⚠️ Service Worker Avançado (8-12h)
8. ⚠️ Database Connection Pooling (4-6h)
9. ⚠️ Background Jobs Expansion (12-16h)
10. ⚠️ HTTP/2 Server Push (4-6h)

**Total Esforço**: 28-40 horas
**Impacto Combinado**: 📈 +220% em escalabilidade

---

### Long Term (Fazer PRÓXIMO TRIMESTRE)
11. 📋 CDN Implementation (8-12h)
12. 📋 APM/Monitoring (6-10h)
13. 📋 Web Vitals Tracking (10-14h)

**Total Esforço**: 24-36 horas
**Impacto Combinado**: 📈 Observability completa

---

## 🎯 Métricas de Sucesso

### Antes vs Depois (Projeções)

| Métrica | Antes | Meta | Melhoria |
|---------|-------|------|----------|
| **Time to First Byte (TTFB)** | ~800ms | ~200ms | -75% |
| **Largest Contentful Paint (LCP)** | ~2.5s | ~1.2s | -52% |
| **First Input Delay (FID)** | ~100ms | ~50ms | -50% |
| **Cumulative Layout Shift (CLS)** | 0.15 | <0.1 | -33% |
| **Total Bundle Size** | ~450KB | ~280KB | -38% |
| **Database Query Time** | ~150ms | ~50ms | -67% |
| **Cache Hit Rate** | 0% | 80% | +∞ |
| **Concurrent Users** | ~100 | ~500 | +400% |

---

## 🛠️ Plano de Ação Recomendado

### Semana 1: Quick Wins
**Segunda**: Loading States + Bullet Setup
**Terça**: Identificar e corrigir N+1 queries
**Quarta**: Implementar Russian Doll Caching
**Quinta**: Testar e ajustar cache strategy
**Sexta**: Deploy e monitoramento

**Resultado Esperado**: +50% em performance percebida

---

### Semana 2: High Impact
**Segunda**: Lazy Loading de Imagens
**Terça**: Skeleton Screens (componentes)
**Quarta**: Skeleton Screens (implementação)
**Quinta**: Code Splitting e Preloading
**Sexta**: Testes de performance e ajustes

**Resultado Esperado**: +40% em métricas Core Web Vitals

---

### Semana 3-4: Strategic
**Semana 3**: Service Worker + Background Jobs
**Semana 4**: HTTP/2 + Database Pooling

**Resultado Esperado**: Sistema pronto para escala 5x

---

## 📈 ROI Estimado

### Investimento Total
- **Tempo**: 82-128 horas (~2-3 meses part-time)
- **Custo**: $0 (apenas tempo de desenvolvimento)
- **Ferramentas**: APM ($99/mês), CDN ($20/mês)

### Retorno Esperado
- **Performance**: +150% melhoria geral
- **UX**: +40% em satisfação do usuário
- **Escalabilidade**: +400% capacidade de usuários
- **Custos Infraestrutura**: -30% (melhor uso de recursos)
- **Tempo de Desenvolvimento**: -20% (debug mais fácil)

**ROI Total**: 🚀 **+500% em 6 meses**

---

## ✅ Checklist de Implementação

### Performance
- [ ] Loading states implementados
- [ ] N+1 queries eliminados
- [ ] Russian Doll Caching ativo
- [ ] Lazy loading de imagens
- [ ] Code splitting configurado
- [ ] HTTP/2 ativo
- [ ] Brotli compression ativa

### UX
- [ ] Skeleton screens criados
- [ ] Loading indicators consistentes
- [ ] Error boundaries implementados
- [ ] Offline fallbacks funcionando
- [ ] Transitions suaves

### Infrastructure
- [ ] Database pooling otimizado
- [ ] Background jobs expandidos
- [ ] Service worker avançado
- [ ] CDN configurado (opcional)

### Monitoring
- [ ] APM instalado e configurado
- [ ] Web Vitals tracking ativo
- [ ] Error tracking aprimorado
- [ ] Performance dashboards criados

---

## 🎓 Recursos e Referências

### Performance
- [Rails Performance Guide](https://guides.rubyonrails.org/performance_testing.html)
- [Hotwire Performance](https://hotwired.dev)
- [Web.dev Performance](https://web.dev/performance/)

### Tools
- [Bullet Gem](https://github.com/flyerhzm/bullet)
- [Scout APM](https://scoutapm.com)
- [Web Vitals](https://github.com/GoogleChrome/web-vitals)

### Best Practices
- [Rails Caching Guide](https://guides.rubyonrails.org/caching_with_rails.html)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Stimulus Best Practices](https://stimulus.hotwired.dev/handbook/introduction)

---

**Última atualização**: 28 de Outubro de 2025
**Status**: 📋 Ready for Implementation
**Próxima Revisão**: Após implementação das Quick Wins
