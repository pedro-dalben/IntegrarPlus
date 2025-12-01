# Módulo PdfHeaderFooter - Guia de Uso

O módulo `PdfHeaderFooter` fornece header e footer padronizados para todos os documentos PDF gerados no sistema usando Prawn.

## Como Usar

### 1. Incluir o módulo no seu service

```ruby
class MeuPdfService
  include PdfHeaderFooter

  def generate_pdf
    pdf = create_pdf_with_header_footer
    # Seu código aqui
    pdf
  end
end
```

### 2. Criar um PDF com header/footer

Use o método helper `create_pdf_with_header_footer`:

```ruby
# Padrão (A4, portrait)
pdf = create_pdf_with_header_footer

# Customizado
pdf = create_pdf_with_header_footer(page_size: 'LETTER', page_layout: :landscape)
```

### 3. Renderizar conteúdo respeitando header/footer

Use o método `content_area_bounding_box` para garantir que o conteúdo não sobreponha header/footer:

```ruby
def render_content(pdf, content)
  content_area_bounding_box(pdf) do
    pdf.font 'Helvetica'
    pdf.text content
    # Seu conteúdo aqui
  end
end
```

## Exemplo Completo

```ruby
require 'prawn'

class ExemploPdfService
  include PdfHeaderFooter

  def generate_relatorio(data)
    pdf = create_pdf_with_header_footer
    
    content_area_bounding_box(pdf) do
      pdf.font 'Helvetica'
      pdf.font_size 12
      
      pdf.text "Relatório de #{data[:periodo]}", 
               size: 16, 
               style: :bold, 
               align: :center
      
      pdf.move_down 20
      
      data[:itens].each do |item|
        pdf.text item[:titulo], style: :bold
        pdf.text item[:descricao]
        pdf.move_down 10
      end
    end
    
    pdf
  end
end
```

## Constantes Disponíveis

- `PdfHeaderFooter::HEADER_HEIGHT` - Altura do header (65pt)
- `PdfHeaderFooter::FOOTER_HEIGHT` - Altura do footer (55pt)
- `PdfHeaderFooter::PAGE_MARGINS` - Margens da página [topo, direita, rodapé, esquerda]

## Métodos Públicos

### `create_pdf_with_header_footer(page_size: 'A4', page_layout: :portrait)`
Cria um novo documento PDF com header e footer já configurados.

### `content_area_bounding_box(pdf, &block)`
Define uma área de conteúdo que respeita automaticamente o espaço do header e footer. O conteúdo dentro do block será renderizado respeitando essas áreas.

## Métodos Privados (disponíveis para uso interno)

- `setup_header_footer(pdf)` - Configura header e footer em todas as páginas
- `draw_header(pdf)` - Desenha o header com logo e subtítulo
- `draw_footer(pdf)` - Desenha o footer com informações da empresa e numeração de páginas

## Características

- Logo aparece em todas as páginas
- Footer padronizado com informações da empresa em todas as páginas
- Numeração automática de páginas no formato `<page> / <total>`
- Conteúdo automaticamente respeita as áreas do header/footer
- Quebras de página automáticas quando necessário

