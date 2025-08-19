# PaginationComponent

Componente reutilizável para exibir paginação usando o gem Pagy com layout centralizado e responsivo.

## Uso

```erb
<%= render Ui::PaginationComponent.new(pagy: @pagy) %>
```

## Parâmetros

- `pagy` (obrigatório): Objeto Pagy gerado pelo controller

## Layout

O componente exibe:
1. **Navegação centralizada** - Botões de navegação (Primeira, Anterior, números, Próxima, Última)
2. **Contador de resultados** - Mostra "Mostrando X a Y de Z resultados"

## Layout Visual

```
    [« Primeira] [‹ Anterior] [1] [2] [3] [Próxima ›] [Última »]
              Mostrando 1 a 10 de 25 resultados
```

## Características

- ✅ **Centralizado**: Layout vertical com navegação centralizada
- ✅ **Responsivo**: Se adapta a diferentes tamanhos de tela  
- ✅ **Acessível**: Usa helper pagy_nav com navegação semântica
- ✅ **Consistente**: Mesmo estilo em todas as telas

## Implementação nos Controllers

```ruby
def index
  @pagy, @records = if params[:query].present?
    pagy(Model.search(params[:query]), limit: 10)
  else
    pagy(Model.all, limit: 10)
  end
end
```

## Views que usam o componente

- `/admin/specializations` - Especializações
- `/admin/specialities` - Especialidades  
- `/admin/professionals` - Profissionais
- `/admin/contract_types` - Tipos de Contrato

## Configuração

O componente usa o helper `pagy_nav` customizado definido em `ApplicationHelper` que:
- Usa caracteres Unicode limpos (« ‹ › ») 
- Aplica classes Tailwind CSS
- Suporta modo escuro
- Inclui transições suaves
