# UX - Módulo Professionals

## Comportamento Geral

### Interface Responsiva
- **Desktop**: Tabela completa com todas as colunas
- **Tablet**: Colunas menos críticas ocultas
- **Mobile**: Apenas Nome, Status e Ações visíveis

### Navegação
- **Linha clicável**: Clique em linha da tabela navega para detalhes
- **Exceções**: Links e botões não disparam navegação
- **Foco**: Indicador visual de hover e foco

## Formulário de Profissional

### Seções Organizadas
1. **Dados Pessoais**: Informações básicas
2. **Acesso e Status**: Controle de login e confirmação
3. **Vínculos e Carga**: Contratação e carga horária
4. **Permissões e Competências**: Grupos e especialidades

### Máscaras de Entrada

#### CPF
- **Formato**: 000.000.000-00
- **Validação**: CPF válido
- **Comportamento**: Aplicação automática da máscara

#### CNPJ
- **Formato**: 00.000.000/0000-00
- **Validação**: CNPJ válido (quando presente)
- **Comportamento**: Aplicação automática da máscara

#### Telefone
- **Formatos**: (00) 00000-0000 ou (00) 0000-0000
- **Validação**: Formato BR válido
- **Comportamento**: Adaptação automática ao tamanho

### Datepicker
- **Formato**: dd/mm/yyyy
- **Calendário**: Interface visual
- **Entrada manual**: Permitida
- **Validação**: Data válida e dentro do range

### Conversão HH:MM → Minutos
- **Input visual**: HH:MM (ex: 40:00)
- **Validação**: 00:00–99:59
- **Conversão**: Automática para minutos
- **Feedback**: Formatação em tempo real

### Campos Condicionais

#### Comportamento por ContractType
- **CLT**: Campos empresa/CNPJ ocultos
- **PJ**: Campos empresa/CNPJ visíveis e obrigatórios
- **Autônomo**: Campos empresa/CNPJ ocultos

#### Transições
- **Aparecer**: Fade in suave
- **Desaparecer**: Fade out suave
- **Limpeza**: Valores limpos quando ocultos

### Multiselect com Busca

#### Grupos
- **Seleção**: Múltipla
- **Busca**: Em tempo real
- **Placeholder**: "Selecione os grupos..."
- **Remoção**: Botão X individual

#### Especialidades
- **Seleção**: Múltipla
- **Busca**: Em tempo real
- **Dependência**: Afeta especializações
- **Placeholder**: "Selecione as especialidades..."

#### Especializações
- **Seleção**: Múltipla
- **Dependência**: Baseada nas especialidades
- **Preservação**: Seleções válidas mantidas
- **Limpeza**: Seleções inválidas removidas

## Listagem de Profissionais

### Tabela Responsiva
- **Desktop**: Todas as colunas visíveis
- **Tablet**: CPF e telefone ocultos
- **Mobile**: Apenas nome, status e ações

### Busca
- **Campo**: Busca em tempo real
- **Escopo**: Nome, e-mail, CPF
- **Performance**: Client-side
- **Placeholder**: "Buscar profissionais..."

### Status Visual
- **Ativo**: Badge verde
- **Inativo**: Badge vermelho
- **Confirmado**: Badge azul
- **Pendente**: Badge amarelo

### Ações
- **Ver**: Navega para detalhes
- **Editar**: Abre formulário de edição
- **Menu**: Dropdown com ações administrativas

## Detalhes do Profissional

### Layout
- **Avatar**: Iniciais em círculo
- **Dados principais**: Nome e e-mail em destaque
- **Status**: Badges no topo
- **Seções**: Cards organizados

### Informações
- **Dados pessoais**: CPF, telefone, nascimento
- **Vínculos**: Contratação, data, carga horária
- **Condicionais**: Empresa/CNPJ se aplicável
- **Associações**: Grupos, especialidades, especializações

### Ações Administrativas
- **Reenviar confirmação**: Para não confirmados
- **Resetar senha**: Sempre disponível
- **Forçar confirmação**: Para não confirmados
- **Excluir**: Sempre disponível

## Estados de Erro

### Validação de Formulário
- **Campos obrigatórios**: Borda vermelha
- **Formato inválido**: Borda vermelha + mensagem
- **CPF/CNPJ inválido**: Mensagem específica
- **Dependências**: Mensagem contextual

### Feedback Visual
- **Alertas**: Cards com ícone e mensagem
- **Auto-dismiss**: Desaparecem automaticamente
- **Ações**: Botão para fechar manualmente

### Mensagens de Erro
- **Amigáveis**: Linguagem clara
- **Contextuais**: Explicam o problema
- **Sugestivas**: Indicam como corrigir

## Acessibilidade

### Navegação por Teclado
- **Tab**: Navega entre campos
- **Enter**: Submete formulários
- **Escape**: Fecha dropdowns
- **Setas**: Navega em selects

### Screen Readers
- **Labels**: Associados aos campos
- **Descrições**: Texto auxiliar
- **Estados**: Anúncio de mudanças
- **Erros**: Anúncio de validações

### Contraste e Cores
- **Status**: Cores com contraste adequado
- **Erros**: Vermelho acessível
- **Sucesso**: Verde acessível
- **Links**: Azul com underline

## Performance

### Carregamento
- **Lazy loading**: Especializações sob demanda
- **Cache**: Dados de especialidades
- **Otimização**: Queries eficientes

### Interações
- **Debounce**: Busca com delay
- **Throttle**: Scroll e resize
- **Feedback**: Loading states

## Casos de Uso

### Criar Profissional CLT
1. Preencher dados pessoais
2. Selecionar "CLT"
3. Campos empresa/CNPJ não aparecem
4. Definir carga horária
5. Selecionar especialidades
6. Especializações carregam automaticamente

### Criar Profissional PJ
1. Preencher dados pessoais
2. Selecionar "PJ"
3. Campos empresa/CNPJ aparecem
4. Preencher dados da empresa
5. Definir carga horária
6. Selecionar especialidades e especializações

### Editar Profissional
1. Carregar dados existentes
2. Campos condicionais já configurados
3. Especializações pré-selecionadas
4. Validações aplicadas
5. Salvar alterações

### Ações Administrativas
1. **Reenviar confirmação**: Botão só aparece para não confirmados
2. **Resetar senha**: Sempre disponível
3. **Forçar confirmação**: Botão só aparece para não confirmados
4. **Excluir**: Confirmação obrigatória
