# Sistema de Dependência - Especialidades e Especializações

## Visão Geral

O sistema permite que as especializações disponíveis sejam filtradas dinamicamente baseadas nas especialidades selecionadas pelo usuário. Quando o usuário seleciona ou remove especialidades, as opções de especializações são atualizadas automaticamente.

## Arquitetura

### 1. **Controller Stimulus** (`dependent_specializations_controller.js`)
- Observa mudanças no select de especialidades através de eventos do Tom Select
- Faz requisição AJAX para buscar especializações filtradas
- Atualiza as opções do select de especializações
- Re-inicializa o Tom Select para refletir as mudanças

### 2. **Controller Rails** (`Admin::SpecializationsController`)
- Endpoint `by_speciality` retorna especializações filtradas
- Aceita parâmetros `speciality_ids[]` para filtrar
- Retorna JSON com id, nome e nome da especialidade

### 3. **Modelo** (`Specialization`)
- Relacionamento many-to-many com `Speciality`
- Scope `by_speciality` para filtrar por IDs de especialidades

## Implementação

### Controller Stimulus

```javascript
export default class extends Controller {
  static targets = ['specialitySelect', 'specializationSelect'];
  
  connect() {
    this.initializeSpecializations();
    this.waitForTomSelectAndSetupListeners();
  }
  
  // Aguarda a inicialização do Tom Select antes de configurar listeners
  waitForTomSelectAndSetupListeners() {
    const maxAttempts = 10;
    let attempts = 0;
    
    const checkTomSelect = () => {
      attempts++;
      const specialityTomSelect = this.specialitySelectTarget.tomselect;
      if (specialityTomSelect) {
        this.setupTomSelectListeners();
      } else if (attempts < maxAttempts) {
        setTimeout(checkTomSelect, 100);
      }
    };
    
    checkTomSelect();
  }
  
  // Configura listeners para eventos do Tom Select
  setupTomSelectListeners() {
    const specialityTomSelect = this.specialitySelectTarget.tomselect;
    if (specialityTomSelect) {
      specialityTomSelect.on('change', () => {
        this.specialityChanged();
      });
      
      specialityTomSelect.on('item_add', () => {
        this.specialityChanged();
      });
      
      specialityTomSelect.on('item_remove', () => {
        this.specialityChanged();
      });
    }
  }
  
  // Carrega especializações baseadas nas especialidades selecionadas
  async loadSpecializations() {
    const specialityIds = Array.from(this.specialitySelectTarget.selectedOptions)
      .map(option => option.value);
    
    // Faz requisição AJAX
    const response = await fetch(`/admin/specializations/by_speciality?speciality_ids[]=${specialityIds.join('&speciality_ids[]=')}`);
    const data = await response.json();
    
    // Atualiza opções
    this.updateSpecializationOptions(data);
    
    // Re-inicializa Tom Select
    this.reinitializeTomSelect();
  }
}
```

### Controller Rails

```ruby
def by_speciality
  speciality_ids = params[:speciality_ids] || []
  
  specializations = Specialization.joins(:specialities)
                                .where(specialities: { id: speciality_ids })
                                .includes(:specialities)
                                .order(:name)
  
  result = specializations.map do |spec|
    {
      id: spec.id,
      name: spec.name,
      speciality_name: spec.specialities.first&.name || 'N/A'
    }
  end
  
  render json: result
end
```

### View (Formulário)

```erb
<!-- Select de Especialidades -->
<div data-controller="tom-select dependent-specializations"
     data-dependent-specializations-endpoint-value="/admin/specializations/by_speciality">
  <%= form.select :speciality_ids,
      @specialities.map { |s| [s.name, s.id] },
      { prompt: "Selecione as especialidades..." },
      {
        multiple: true,
        data: {
          tom_select_target: "select",
          dependent_specializations_target: "specialitySelect",
          tom_select_options_value: { ... }.to_json
        }
      } %>
</div>

<!-- Select de Especializações -->
<div data-controller="tom-select dependent-specializations">
  <%= form.select :specialization_ids,
      [],
      { prompt: "Selecione as especializações..." },
      {
        multiple: true,
        data: {
          tom_select_target: "select",
          dependent_specializations_target: "specializationSelect",
          tom_select_options_value: { ... }.to_json
        }
      } %>
</div>
```

## Fluxo de Funcionamento

### 1. **Inicialização**
```
Usuário abre formulário → Controller conecta → Aguarda Tom Select inicializar → Configura listeners
```

### 2. **Seleção de Especialidade**
```
Usuário seleciona especialidade → Tom Select dispara evento → Controller observa mudança
```

### 3. **Busca de Especializações**
```
Controller faz requisição AJAX → Endpoint retorna especializações filtradas → Controller atualiza opções
```

### 4. **Atualização da Interface**
```
Controller atualiza HTML → Re-inicializa Tom Select → Interface reflete mudanças
```

## Configuração

### Rotas

```ruby
# config/routes.rb
namespace :admin do
  resources :specializations do
    collection do
      get :by_speciality, defaults: { format: :json }
    end
  end
end
```

### Autorização

```ruby
# app/policies/specialization_policy.rb
def by_speciality?
  user.permit?('settings.read')
end
```

### Relacionamentos

```ruby
# app/models/specialization.rb
has_many :specialization_specialities, dependent: :destroy
has_many :specialities, through: :specialization_specialities

scope :by_speciality, ->(speciality_ids) { 
  joins(:specialities).where(specialities: { id: speciality_ids }) 
}
```

## Tratamento de Erros

### Controller Stimulus
- Logs detalhados para debug
- Tratamento de erros de rede
- Fallback para estado de erro
- Aguarda inicialização do Tom Select antes de configurar listeners

### Controller Rails
- Validação de parâmetros
- Tratamento de exceções
- Logs para auditoria

## Debug e Logs

### Console do Navegador
```javascript
// Logs do controller Stimulus
console.log('DependentSpecializationsController conectado');
console.log('Tentativa X de configurar listeners do Tom Select');
console.log('Tom Select encontrado, configurando listeners');
console.log('Listeners configurados com sucesso');
console.log('Evento change disparado no Tom Select');
console.log('Item adicionado/removido do Tom Select');
console.log('IDs das especialidades selecionadas:', specialityIds);
console.log('Fazendo requisição para:', url.toString());
console.log('Dados recebidos:', data);
```

### Logs do Rails
```ruby
Rails.logger.info "Buscando especializações para especialidades: #{speciality_ids}"
Rails.logger.info "Encontradas #{specializations.count} especializações"
Rails.logger.info "Resultado: #{result.inspect}"
```

## Problemas Comuns e Soluções

### 1. **Erro: "Action references undefined method"**
**Problema**: O método `specialityChanged` não é encontrado
**Solução**: Remover a action `change->dependent-specializations#specialityChanged` do formulário e usar eventos nativos do Tom Select

### 2. **Tom Select não inicializado**
**Problema**: Controller tenta configurar listeners antes do Tom Select estar pronto
**Solução**: Implementar `waitForTomSelectAndSetupListeners()` que aguarda a inicialização

### 3. **Eventos não disparados**
**Problema**: Tom Select não dispara eventos `change` padrão
**Solução**: Usar eventos específicos do Tom Select: `change`, `item_add`, `item_remove`

### 4. **Opções não aparecem no Tom Select**
**Problema**: Tom Select não exibe as opções atualizadas após mudanças
**Solução**: Implementar re-inicialização completa do Tom Select com `clearOptions()`, `addOption()` e `refreshOptions()`

### 5. **Targets não encontrados**
**Problema**: Controller não consegue encontrar os elementos target
**Solução**: Verificar se o controller está aplicado ao elemento pai correto que contenha todos os targets

## Testes

### Teste Manual
1. Abrir formulário de profissional
2. Selecionar especialidades
3. Verificar se especializações são filtradas
4. Desmarcar especialidades
5. Verificar se especializações são limpas

### Teste Automatizado
```ruby
# spec/controllers/admin/specializations_controller_spec.rb
describe 'GET #by_speciality' do
  it 'retorna especializações filtradas por especialidades' do
    get :by_speciality, params: { speciality_ids: [speciality.id] }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to be_an(Array)
  end
end
```

### Arquivo de Teste HTML
Um arquivo `test_dependent_specializations.html` foi criado para testar a funcionalidade independentemente do Rails.

## Manutenção

### Adicionar Novos Campos
1. Atualizar o controller Rails para incluir novos campos
2. Atualizar o controller Stimulus para processar novos dados
3. Atualizar a view para exibir novos campos

### Alterar Lógica de Filtro
1. Modificar o scope `by_speciality` no modelo
2. Atualizar o controller Rails se necessário
3. Testar com diferentes combinações de especialidades

### Performance
- Usar `includes` para evitar N+1 queries
- Considerar cache para consultas frequentes
- Monitorar tempo de resposta do endpoint

## Conclusão

O sistema de dependência entre especialidades e especializações oferece:
- ✅ **Filtragem dinâmica** baseada em seleções do usuário
- ✅ **Interface responsiva** com atualizações em tempo real
- ✅ **Tratamento robusto de erros** e logs para debug
- ✅ **Integração perfeita** com Tom Select
- ✅ **Performance otimizada** com queries eficientes
- ✅ **Inicialização robusta** que aguarda dependências

**Resultado**: Experiência do usuário fluida e intuitiva, com especializações sempre relevantes às especialidades selecionadas.

## Atualização do Tom Select

### Problema Comum
Após atualizar as opções do select HTML, o Tom Select não exibe as novas opções. Isso acontece porque o Tom Select mantém suas próprias opções internas que precisam ser sincronizadas.

### Solução: Re-inicialização Completa

```javascript
reinitializeTomSelect() {
  const tomSelectInstance = this.specializationSelectTarget.tomselect;
  if (tomSelectInstance) {
    console.log('Re-inicializando Tom Select');
    
    // 1. Limpar seleções atuais
    tomSelectInstance.clear();
    
    // 2. Limpar opções existentes
    tomSelectInstance.clearOptions();
    
    // 3. Adicionar opção padrão
    tomSelectInstance.addOption({
      value: '',
      text: 'Selecione as especializações...'
    });
    
    // 4. Adicionar todas as opções do select HTML
    const options = Array.from(this.specializationSelectTarget.options);
    options.forEach(option => {
      if (option.value !== '') {
        tomSelectInstance.addOption({
          value: option.value,
          text: option.textContent
        });
      }
    });
    
    // 5. Forçar atualização da interface
    tomSelectInstance.refreshOptions();
    tomSelectInstance.refreshItems();
    
    console.log('Tom Select re-inicializado com sucesso');
  }
}
```

### Fluxo de Atualização

1. **Receber dados** da API
2. **Atualizar HTML** do select nativo
3. **Re-inicializar Tom Select** com as novas opções
4. **Forçar refresh** da interface

### Métodos do Tom Select Utilizados

- `clear()` - Remove todas as seleções
- `clearOptions()` - Remove todas as opções disponíveis
- `addOption()` - Adiciona uma nova opção
- `refreshOptions()` - Atualiza a lista de opções na interface
- `refreshItems()` - Atualiza os itens selecionados na interface

### Exemplo de Implementação

```javascript
async loadSpecializations() {
  // ... código de requisição ...
  
  const data = await response.json();
  console.log('Dados recebidos:', data);

  // 1. Limpar opções existentes
  this.specializationSelectTarget.innerHTML = '';
  
  // 2. Adicionar opção padrão
  const defaultOption = document.createElement('option');
  defaultOption.value = '';
  defaultOption.textContent = 'Selecione as especializações...';
  this.specializationSelectTarget.appendChild(defaultOption);

  // 3. Adicionar novas opções
  data.forEach(specialization => {
    const option = document.createElement('option');
    option.value = specialization.id;
    option.textContent = `${specialization.name} (${specialization.speciality_name})`;
    this.specializationSelectTarget.appendChild(option);
  });

  // 4. Re-inicializar Tom Select
  this.reinitializeTomSelect();
}
```
