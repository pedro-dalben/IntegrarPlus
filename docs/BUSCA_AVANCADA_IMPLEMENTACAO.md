# Implementação de Busca Avançada

## Problema Identificado

O sistema de busca de documentos apresentava problemas de eficiência:
- Busca inconsistente, às vezes não encontrava itens
- Falta de suporte a busca fonética
- Não tratava caracteres especiais adequadamente
- Experiência do usuário limitada

## Soluções Implementadas

### 1. Serviço de Busca Avançada

Criado o `AdvancedSearchService` (`app/services/advanced_search_service.rb`) que implementa múltiplas estratégias de busca:

#### Estratégias de Busca:
- **Busca Exata**: Correspondência direta dos termos
- **Busca Fonética**: Usando algoritmo Metaphone para palavras similares
- **Busca Normalizada**: Tratamento de caracteres especiais (acentos, cedilha)
- **Busca Parcial**: Suporte a wildcards (*)
- **Busca Fuzzy**: Tolerância a erros de digitação

#### Características:
- Debounce automático (300ms padrão)
- Cancelamento de requisições em andamento
- Fallback para busca local em caso de erro
- Ordenação por relevância personalizada

### 2. Melhorias no Modelo Document

#### Atributos de Busca Adicionados:
```ruby
# Atributos para busca fonética
attribute :phonetic_title
attribute :phonetic_description
attribute :phonetic_author_name

# Atributos para busca com caracteres especiais
attribute :normalized_title
attribute :normalized_description
```

#### Métodos de Normalização:
- `normalize_text()`: Remove caracteres especiais
- `normalize_special_chars()`: Normaliza acentos e cedilha
- `generate_phonetic()`: Gera código fonético usando Metaphone

### 3. Controller Stimulus Avançado

Criado `AdvancedSearchController` (`app/frontend/javascript/controllers/advanced_search_controller.js`) com:

#### Funcionalidades:
- **Debounce Inteligente**: Evita requisições excessivas
- **Feedback Visual**: Loading, erro, sugestões
- **Cancelamento de Requisições**: AbortController para requisições antigas
- **Sugestões de Busca**: Dicas para melhorar a busca
- **Tratamento de Erros**: Fallback gracioso

#### Configurações:
- Debounce: 500ms (configurável)
- Comprimento mínimo: 2 caracteres
- Timeout automático para requisições

### 4. Configurações MeiliSearch Otimizadas

#### Ranking Rules:
```ruby
ranking_rules %w[
  words
  typo
  proximity
  attribute
  sort
  exactness
]
```

#### Tolerância a Erros:
```ruby
typo_tolerance do
  enabled true
  min_word_size_for_typos do
    one_typo 4
    two_typos 8
  end
end
```

#### Stop Words em Português:
```ruby
stop_words %w[o a os as um uma uns umas e é de da do das dos em na no nas nos por para com sem sob sobre entre contra desde até]
```

### 5. Interface de Usuário Melhorada

#### Componentes Adicionados:
- **Indicador de Loading**: Spinner animado
- **Mensagens de Erro**: Feedback claro sobre problemas
- **Sugestões de Busca**: Dicas contextuais
- **Cards de Documento**: Layout mais informativo

#### Melhorias Visuais:
- Hover effects suaves
- Transições CSS
- Ícones informativos
- Layout responsivo

## Como Usar

### Busca Básica:
Digite normalmente no campo de busca. O sistema irá:
1. Normalizar o texto
2. Aplicar busca fonética
3. Tratar caracteres especiais
4. Ordenar por relevância

### Busca Avançada:
- **Aspas**: `"relatório técnico"` - busca exata
- **Wildcard**: `relator*` - busca parcial
- **Tipo**: `tipo:relatorio` - filtrar por tipo
- **Autor**: `autor:"João Silva"` - buscar por autor

### Dicas de Performance:
- O sistema usa debounce para evitar requisições excessivas
- Requisições antigas são canceladas automaticamente
- Fallback para busca local em caso de erro do MeiliSearch

## Configuração

### Variáveis de Ambiente:
```bash
MEILISEARCH_HOST=http://localhost:7700
MEILISEARCH_API_KEY=sua_chave_aqui
```

### Gems Adicionadas:
```ruby
gem 'text'  # Para busca fonética
```

### Comandos Úteis:
```bash
# Reindexar todos os documentos
bundle exec rails meilisearch:reindex

# Reindexar apenas documentos
bundle exec rails meilisearch:reindex Document

# Verificar status do MeiliSearch
curl http://localhost:7700/health
```

## Monitoramento

### Logs:
- Erros de busca são logados com stack trace
- Performance de busca é monitorada
- Fallbacks são registrados

### Métricas:
- Tempo de resposta da busca
- Taxa de sucesso vs fallback
- Queries mais populares

## Próximos Passos

1. **Analytics de Busca**: Implementar tracking de queries
2. **Sugestões Inteligentes**: Baseadas no histórico
3. **Busca Semântica**: Usando embeddings
4. **Cache Inteligente**: Para queries frequentes
5. **Busca em Conteúdo**: Extrair texto de PDFs

## Troubleshooting

### MeiliSearch não responde:
```bash
# Verificar se está rodando
ps aux | grep meilisearch

# Iniciar se necessário
meilisearch --http-addr localhost:7700 &

# Verificar logs
tail -f /var/log/meilisearch.log
```

### Busca lenta:
- Verificar configurações de ranking
- Otimizar atributos searchable
- Ajustar debounce se necessário

### Resultados inconsistentes:
- Reindexar documentos
- Verificar configurações de filtros
- Validar atributos fonéticos
