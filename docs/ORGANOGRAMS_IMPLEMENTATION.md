# Sistema de Organogramas - IntegrarPlus

## 📋 Visão Geral

Sistema completo de gerenciamento de organogramas utilizando **DHTMLX Diagram** (DHX Suite) integrado ao projeto Ruby on Rails + Vite + PostgreSQL.

## 🎯 Funcionalidades Implementadas

### ✅ CRUD Completo
- ✅ Listagem de organogramas com paginação
- ✅ Criação de novos organogramas
- ✅ Visualização (modo somente leitura)
- ✅ Editor completo com interface drag & drop
- ✅ Exclusão de organogramas

### ✅ Editor Avançado
- ✅ Interface de três painéis (controles, canvas, propriedades)
- ✅ Editor de nós com propriedades (nome, título, departamento, email, telefone)
- ✅ Adição/remoção de nós com hierarquia
- ✅ Auto-save com debounce de 800ms
- ✅ Controles de zoom (in, out, fit to screen)
- ✅ Atalhos de teclado (Ctrl+S para salvar, Del para remover)

### ✅ Importação/Exportação
- ✅ **Exportação JSON**: Dados completos do organograma
- ✅ **Exportação PDF** (client-side): Usando html2canvas + jsPDF
- ✅ **Importação JSON**: Substituição completa dos dados
- ✅ **Importação CSV**: Processamento com validação e normalização
- ✅ Arquivos de exemplo fornecidos

### ✅ Sistema de Permissões
- ✅ Integração com Pundit
- ✅ Níveis de acesso: admin/secretaria (CRUD completo), visualizador (somente leitura)
- ✅ Controle de publicação/despublicação

### ✅ Internacionalização
- ✅ Tradução completa PT-BR
- ✅ Mensagens de erro localizadas
- ✅ Interface em português

### ✅ Dados de Exemplo
- ✅ Seeds com 3 organogramas de exemplo
- ✅ Arquivos de exemplo (JSON/CSV) em `spec/fixtures/`
- ✅ Membros de organograma para demonstração

## 🏗️ Arquitetura

### Backend (Ruby on Rails)

#### Modelos
- **`Organogram`**: Modelo principal com dados em JSONB
  - `name`: Nome do organograma
  - `data`: Estrutura de nós e links (JSONB)
  - `settings`: Configurações do editor (JSONB)
  - `published_at`: Data de publicação
  - `created_by`: Referência ao usuário criador

- **`OrganogramMember`**: Metadados dos membros
  - `external_id`: ID externo único
  - `name`, `role_title`, `department`, `email`, `phone`
  - `meta`: Dados adicionais (JSONB)

#### Controller
- **`Admin::OrganogramsController`**: CRUD completo + ações especiais
  - Actions: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`
  - Ações especiais: `editor`, `export_json`, `export_pdf`, `import_json`, `import_csv`, `publish`, `unpublish`

#### Políticas de Autorização
- **`OrganogramPolicy`**: Controle de acesso usando Pundit
  - Verificação de permissões por ação
  - Scope para filtrar organogramas por usuário

### Frontend (TypeScript + Vite)

#### Estrutura
```
app/frontend/organograms/
├── editor.ts          # Editor principal (DHX Diagram)
├── show.ts            # Visualizador somente leitura
└── csv.ts             # Utilitários para processamento CSV
```

#### Dependências
- **dhx-suite**: Biblioteca principal para diagramas
- **jspdf**: Geração de PDF client-side
- **html2canvas**: Captura de screenshot para PDF
- **papaparse**: Processamento de arquivos CSV

#### Funcionalidades JavaScript
- **Editor Interativo**: Drag & drop, edição inline, propriedades
- **Auto-save**: Salvamento automático com debounce
- **Exportação PDF**: Captura de alta resolução com paginação automática
- **Validação CSV**: Processamento com detecção de erros e ciclos
- **Toast Notifications**: Feedback visual para ações

## 📁 Estrutura de Arquivos

### Backend
```
app/
├── controllers/admin/organograms_controller.rb
├── models/
│   ├── organogram.rb
│   └── organogram_member.rb
├── policies/organogram_policy.rb
└── views/admin/organograms/
    ├── index.html.erb
    ├── new.html.erb
    ├── show.html.erb
    └── editor.html.erb

db/
├── migrate/
│   ├── create_organograms.rb
│   └── create_organogram_members.rb
└── seeds/organograms.rb

config/
├── routes.rb (rotas adicionadas)
└── locales/organograms.pt-BR.yml
```

### Frontend
```
app/frontend/
├── entrypoints/organograms.js
└── organograms/
    ├── editor.ts
    ├── show.ts
    └── csv.ts

spec/fixtures/organograms/
├── organogram_example.json
└── organogram_example.csv
```

## 🚀 Como Usar

### 1. Instalação
```bash
# Instalar dependências
bundle install
npm install

# Executar migrações
rails db:migrate

# Carregar dados de exemplo
rails db:seed
```

### 2. Acessar o Sistema
- **Lista**: `/admin/organograms`
- **Novo**: `/admin/organograms/new`
- **Editor**: `/admin/organograms/:id/editor`
- **Visualizar**: `/admin/organograms/:id`

### 3. Usar o Editor
1. **Criar Organograma**: Clique em "Novo Organograma"
2. **Editar**: Clique em "Editar" ou acesse `/admin/organograms/:id/editor`
3. **Adicionar Nós**: Selecione um nó e clique em "Adicionar Filho"
4. **Editar Propriedades**: Selecione um nó e edite no painel direito
5. **Salvar**: Auto-save ativo ou Ctrl+S manual
6. **Exportar**: Use botões de exportação (JSON/PDF)

### 4. Importar Dados
- **JSON**: Upload de arquivo JSON com estrutura completa
- **CSV**: Upload com colunas: `id,pid,name,role_title,department,email,phone`

## 🎛️ Configurações

### Exportação PDF Server-side (Opcional)
Para habilitar exportação PDF no servidor:

1. Adicionar gem `grover` ao Gemfile:
```ruby
gem 'grover'
```

2. Configurar variável de ambiente:
```bash
export ORGCHART_PDF_SERVER=true
```

3. Instalar Chromium no servidor:
```bash
# Ubuntu/Debian
sudo apt-get install chromium-browser
```

## 📝 Exemplos de Uso

### Estrutura JSON
```json
{
  "name": "Organograma Empresa",
  "nodes": [
    {
      "id": "ceo",
      "text": "João Silva",
      "title": "CEO",
      "type": "card",
      "data": {
        "department": "Diretoria",
        "email": "joao@empresa.com",
        "phone": "11999990001"
      }
    },
    {
      "id": "cto",
      "text": "Maria Santos",
      "title": "CTO",
      "parent": "ceo",
      "type": "card",
      "data": {
        "department": "Tecnologia",
        "email": "maria@empresa.com",
        "phone": "11999990002"
      }
    }
  ],
  "links": [],
  "settings": {
    "layout": "org",
    "theme": "default",
    "zoom": 1
  }
}
```

### Estrutura CSV
```csv
id,pid,name,role_title,department,email,phone
ceo,,João Silva,CEO,Diretoria,joao@empresa.com,(11) 99999-0001
cto,ceo,Maria Santos,CTO,Tecnologia,maria@empresa.com,(11) 99999-0002
```

## 🔧 Manutenção

### Validações
- **Hierarquia**: Verificação automática de ciclos
- **Dados**: Validação de estrutura JSON
- **CSV**: Normalização e validação de dados

### Performance
- **Auto-save**: Debounce otimizado
- **Renderização**: Canvas otimizado para grandes organigramas
- **PDF**: Paginação automática para organigramas grandes

### Monitoramento
- **Logs**: Erros de importação/exportação registrados
- **Validação**: Feedback em tempo real
- **Notificações**: Toast para feedback visual

## 🧪 Testes

### Dados de Teste
- 3 organogramas de exemplo criados via seeds
- Arquivos de exemplo em `spec/fixtures/organograms/`
- Cobertura de diferentes cenários (empresa, hospital, TI)

### Validação Manual
1. Criar novo organograma
2. Testar editor com adição/remoção de nós
3. Testar importação JSON/CSV
4. Testar exportação PDF/JSON
5. Verificar permissões por tipo de usuário

## 📚 Documentação Adicional

- **DHX Suite**: [Documentação oficial](https://docs.dhtmlx.com/suite/)
- **jsPDF**: [Documentação](https://artskydj.github.io/jsPDF/docs/)
- **html2canvas**: [Documentação](https://html2canvas.hertzen.com/)

## 🎯 Menu e Permissões

### ✅ Navegação
- **Menu Principal**: Item "Organogramas" adicionado ao AdminNav
- **Ícone**: Diagrama organizacional (bi-diagram-3)
- **Posição**: Entre "Cadastros" e "Configurações"
- **Sidebar**: Integrado ao componente sidebar com ícone SVG

### ✅ Sistema de Permissões
Permissões configuradas no sistema:

#### Permissões Disponíveis:
- `organograms.index`: Listar organogramas
- `organograms.show`: Visualizar organogramas
- `organograms.create`: Criar organogramas
- `organograms.update`: Editar organogramas
- `organograms.destroy`: Excluir organogramas
- `organograms.editor`: Usar editor de organogramas
- `organograms.publish`: Publicar organogramas
- `organograms.export`: Exportar organogramas
- `organograms.import`: Importar dados para organogramas

#### Grupos e Acesso:

**🔧 Administradores:**
- ✅ Todas as permissões (CRUD completo + publicação)

**👩‍💼 Secretárias:**
- ✅ CRUD completo + editor + publicação + import/export
- ✅ Gerenciamento total dos organogramas

**👨‍⚕️ Terapeutas:**
- ✅ Visualização + exportação
- ✅ Consulta de estrutura organizacional

**📞 Recepção:**
- ✅ Somente visualização
- ✅ Consulta básica da estrutura

**🩺 Médicos:**
- ✅ Herdam das permissões de Administradores

### 🔄 Acessibilidade
- **URL direta**: `/admin/organograms`
- **Controle de acesso**: Baseado em permissões Pundit
- **Feedback visual**: Menu ativo quando na seção
- **Responsivo**: Interface adaptável a todos dispositivos

## 🔄 Próximos Passos (Opcional)

- [ ] Temas customizáveis para organogramas
- [ ] Histórico de versões
- [ ] Colaboração em tempo real
- [ ] Templates pré-definidos
- [ ] Integração com API externa para sincronização de dados
- [ ] Exportação para outros formatos (PNG, SVG)
- [ ] Dashboard com analytics dos organogramas

---

**Status**: ✅ **Implementação Completa e Funcional**

**Data**: Dezembro 2024
**Versão**: 1.0.0
