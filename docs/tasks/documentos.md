Ótimo ponto, Pedro 👌.
Você está pensando como **um sistema inteiro de gestão documental**, não só um CRUD. Vou revisar **tudo** com base no que levantamos e nas suas novas observações:

* Documentos liberados ficam em **outra tela** (somente a versão final).
* Mesmo após liberado, o documento pode voltar a revisão, gerar nova versão e ser liberado novamente.
* Precisamos pensar em **metodologia de versionamento** clara (ex: semântico adaptado).
* O layout deve refletir **duas áreas distintas**: área de trabalho (com histórico, revisão, tarefas etc.) e área de documentos liberados (somente versão final).
* Documentos precisam ser **armazenados localmente em pastas ignoradas pelo GitHub**, com uma organização clara de diretórios.
Perfeito, Pedro 🙌.
Você quer **prompts nível especialista**, ricos em detalhes técnicos, para que uma IA desenvolvedora consiga implementar sem ambiguidade.
Eu vou refazer cada prompt como se fosse um **documento de especificação + instrução para a IA**, contemplando: contexto, requisitos funcionais e não funcionais, estrutura de dados, regras de negócio, integração entre etapas, persistência e UX esperada.

---

# 📑 Prompts Avançados — Gestão de Documentos (Clínica Integrar)

---

## 1. Upload de Documentos

```markdown
Você é um desenvolvedor especialista em Ruby on Rails 8 + Vite.  
Preciso que você implemente a funcionalidade de **upload de documentos** dentro de um sistema de gestão clínica.  
O fluxo deve obedecer às seguintes especificações:

### Regras de Negócio
- O upload cria a **primeira versão (1.0)** do documento.  
- Documentos devem aceitar: PDF, DOCX, XLSX, JPG e PNG.  
- Cada documento deve possuir metadados obrigatórios: 
  - título (string, até 150 caracteres)  
  - descrição opcional (text)  
  - tipo (enum: relatório, laudo, contrato, outros)  
  - autor (usuário autenticado)  
  - data/hora do envio (auto preenchida)  
  - status inicial = “Aguardando revisão”  
  - versão atual = `1.0`

### Persistência
- Os arquivos devem ser salvos em `/storage/documents/<document_id>/versions/`.  
- O banco de dados guarda apenas o caminho relativo ao arquivo e os metadados.  
- Os arquivos não devem ser versionados pelo Git. Adicione regra no `.gitignore`.

### UX / UI
- Ao fazer upload, mostrar barra de progresso.  
- Após concluir, redirecionar automaticamente para a tela de definição de permissões.  
- Em caso de erro (tamanho excedido, formato inválido, falha no servidor), exibir mensagem clara e registrar log.

### Testes Esperados
- Upload de arquivo válido gera versão 1.0 e cria diretório de armazenamento.  
- Upload de arquivo inválido deve retornar erro 422 JSON + mensagem clara.  
- Apenas usuários autenticados podem fazer upload.
```

---

## 2. Definição de Permissões

```markdown
Implemente o **módulo de permissões de acesso por documento**.

### Regras de Negócio
- Permissões podem ser atribuídas a **usuários individuais** ou **grupos de profissionais**.  
- Tipos de acesso:
  - `visualizar`: pode apenas abrir e baixar documento.  
  - `comentar`: pode visualizar + comentar no histórico/chat.  
  - `editar`: pode visualizar, comentar e subir novas versões.  
- Apenas editores podem alterar permissões.  
- Permissões devem ser verificadas em **cada endpoint** (download, visualização, comentários, upload de versão, liberação).

### Persistência
- Tabela `document_permissions` com colunas: document_id, user_id/group_id, access_level, created_at, updated_at.  
- Os acessos devem ser cacheados para performance (Redis recomendado).  

### UX
- Tela de configuração deve permitir buscar usuários/grupos (autocomplete) e atribuir permissões.  
- Exibir tabela com permissões atuais e opção de remoção.

### Segurança
- Acesso não autorizado deve retornar **403 Forbidden** e registrar no log de auditoria.
```

---

## 3. Histórico de Versões + Chat de Revisão

```markdown
Implemente o **histórico de versões** com chat de revisão integrado.

### Regras de Negócio
- Cada vez que um documento for alterado, gerar nova versão com numeração:
  - X.0 = versão final liberada
  - X.Y = versões intermediárias em revisão
- Histórico deve registrar:
  - número da versão
  - autor da versão
  - data/hora
  - descrição da mudança
- Chat de revisão deve ser vinculado à versão específica.
- Comparação entre versões deve estar disponível (diff de texto quando aplicável).

### Persistência
- Tabela `document_versions` com:
  - document_id
  - version_number (string, ex: “2.1”)
  - file_path
  - created_by
  - notes
- Tabela `version_comments` para chat:
  - version_id
  - user_id
  - comment_text
  - created_at

### UX
- Na tela do documento, exibir linha do tempo das versões.  
- Cada versão deve ter link para abrir/baixar + botão “ver comentários”.  
- Chat estilo “thread” com avatar, nome do autor e data/hora.  

### Segurança
- Apenas quem tem permissão de comentar pode interagir no chat.  
```

---

## 4. To-do List Vinculada

```markdown
Implemente uma **lista de tarefas vinculada a cada documento**.

### Regras de Negócio
- Cada tarefa deve ter: título, descrição, prioridade (alta, média, baixa), criador, responsável e status (pendente/concluída).  
- Conclusão de tarefa deve registrar usuário e data/hora.  
- Itens da lista ficam disponíveis apenas para quem tem acesso ao documento.

### Persistência
- Tabela `document_tasks`:
  - document_id
  - title
  - description
  - priority (enum)
  - created_by
  - assigned_to
  - completed_by
  - completed_at

### UX
- To-do list aparece como aba lateral ao lado do documento.  
- Cores: vermelho = alta, amarelo = média, verde = baixa.  
- Usuários devem poder filtrar tarefas por status (pendente/concluída).  
```

---

## 5. Status do Documento

```markdown
Implemente controle de **status do ciclo de vida do documento**.

### Status possíveis
- Aguardando revisão
- Aguardando correções
- Aguardando liberação
- Liberado

### Regras
- Status inicial = “Aguardando revisão” (upload).  
- Status pode ser atualizado manualmente por editores ou automaticamente:
  - Ao liberar → muda para “Liberado”.  
  - Se adicionada revisão após liberação → volta para “Aguardando revisão”.  
- Histórico de mudanças de status deve ser registrado (quem, quando, qual mudança).

### Persistência
- Tabela `document_status_logs`: document_id, old_status, new_status, user_id, created_at.

### UX
- Exibir status em destaque no cabeçalho da tela.  
- Mostrar timeline com mudanças de status no histórico.
```

---

## 6. Atribuição de Responsáveis

```markdown
Adicione atribuição de **responsáveis por status**.

### Regras
- Cada status pode ter um responsável.  
- O responsável deve receber notificação quando atribuído.  
- Responsável pode ser alterado ao mudar o status.  
- Apenas editores podem atribuir responsáveis.

### Persistência
- Tabela `document_responsibles`: document_id, status, user_id, created_at.

### UX
- No cabeçalho do documento, exibir responsável atual.  
- Dropdown para trocar responsável quando necessário.
```

---

## 7. Liberação de Documento

```markdown
Implemente o fluxo de **liberação de documentos**.

### Regras de Negócio
- Apenas editores podem liberar documento.  
- Ao liberar, criar cópia da versão atual em `/released/` dentro do diretório do documento.  
- Versão liberada recebe incremento de parte inteira (ex: 1.0 → 2.0).  
- Se houver revisão após liberação (2.1, 2.2), a próxima liberação será 3.0.  
- Apenas a última versão liberada fica disponível na tela de “Documentos Liberados”.

### Persistência
- Campo `released_version` no documento.  
- Nova tabela `document_releases`: document_id, version_id, released_by, released_at.

### UX
- Botão “Liberar Documento” disponível apenas para editores.  
- Tela de confirmação: “Deseja liberar versão X.Y como versão final X+1.0?”.  
```

---

## 8. Área de Documentos Liberados

```markdown
Implemente tela de **listagem de documentos liberados**.

### Regras
- Mostrar somente a última versão liberada de cada documento.  
- Exibir: título, autor, versão liberada, data da liberação, responsável.  
- Filtros: tipo de documento, autor, data da liberação.  
- Não exibir histórico, apenas versão final.

### UX
- Listagem estilo tabela com filtros no topo.  
- Ação principal: botão de download/visualização da versão final.
```

---

## 9. Índice de Documentos (Workspace)

```markdown
Crie listagem geral de documentos em andamento (Workspace).

### Regras
- Mostrar: título, autor, versão atual, status, responsável, última modificação.  
- Filtros: por status, responsável, tipo de documento, data.  
- Botão “Meus documentos” deve filtrar onde o usuário é responsável.  
- Paginação recomendada para performance.

### UX
- Listagem em tabela, com ícones visuais indicando status (cores diferentes).  
- Ações rápidas: abrir documento, ver histórico, ver tarefas.
```

---

## 10. Revisão Geral e Integração

```markdown
Realize a integração e validação do fluxo completo:

1. Upload → Permissões → Histórico → Tarefas → Status → Responsável → Liberação → Documentos Liberados.  
2. Validar que permissões funcionam em todos os pontos (ex: quem não tem editar não pode liberar).  
3. Testar versionamento: upload (1.0) → revisão (1.1, 1.2) → liberação (2.0).  
4. Garantir que somente versões finais aparecem em “Documentos Liberados”.  
5. Verificar se logs de auditoria registram: uploads, mudanças de status, permissões, atribuições, liberações.  
6. Testes automatizados (RSpec/Capybara) devem cobrir todos os fluxos.  
```

---

👉 Agora os prompts estão no nível **especialista**, com tudo: regras, persistência, UX, layout esperado, logs, segurança e integração.
Quer que eu monte também um **wireframe em ASCII** para as duas telas principais (Workspace e Documentos Liberados) pra deixar ainda mais claro para a IA como deve ser o layout?
