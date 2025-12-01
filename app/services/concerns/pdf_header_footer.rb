module PdfHeaderFooter
  extend ActiveSupport::Concern

  FOOTER_HEIGHT   = 55
  LOGO_MAX_WIDTH  = 200
  LOGO_MAX_HEIGHT = 90
  LOGO_TOP_MARGIN = 10
  HEADER_HEIGHT   = LOGO_MAX_HEIGHT + LOGO_TOP_MARGIN

  PAGE_MARGINS = [HEADER_HEIGHT + 10, 50, FOOTER_HEIGHT + 20, 50]
  LOGO_PATH    = Rails.root.join('app/assets/images/logo-integrarbaixamogiana.png')

  included do
    private

    def create_pdf_with_header_footer(page_size: 'A4', page_layout: :portrait)
      pdf = Prawn::Document.new(
        page_size: page_size,
        page_layout: page_layout,
        margin: PAGE_MARGINS
      )

      setup_header_footer(pdf)
      pdf
    end

    def setup_header_footer(pdf)
      pdf.repeat(:all, dynamic: true) do
        draw_header(pdf)
        draw_footer(pdf)
      end
    end

    def draw_header(pdf)
      return unless File.exist?(LOGO_PATH)

      natural_width, natural_height = png_dimensions(LOGO_PATH)
      scale = [LOGO_MAX_WIDTH / natural_width.to_f, LOGO_MAX_HEIGHT / natural_height.to_f].min
      actual_width = natural_width * scale

      page_width = pdf.bounds.width
      logo_x = (page_width - actual_width) / 2
      logo_y = pdf.bounds.top + HEADER_HEIGHT - LOGO_TOP_MARGIN

      pdf.image LOGO_PATH.to_s,
                at: [logo_x, logo_y],
                fit: [LOGO_MAX_WIDTH, LOGO_MAX_HEIGHT]
    end

    def png_dimensions(path)
      File.open(path, 'rb') do |f|
        f.read(8)
        f.read(4)
        f.read(4)
        [f.read(4).unpack1('N'), f.read(4).unpack1('N')]
      end
    end

    def draw_footer(pdf)
      footer_y = pdf.bounds.bottom - 25
      page_width = pdf.bounds.width

      pdf.font_size 8 do
        company_text = 'INTEGRAR CENTRO TERAPEUTICO DA BAIXA MOGIANA LTDA'
        company_width = pdf.width_of(company_text, size: 8, style: :bold)
        company_x = (page_width - company_width) / 2

        pdf.draw_text company_text, at: [company_x, footer_y], style: :bold

        address_text = 'CNPJ nº 44.533.956/0001-24 - Rua Sergipe, nº 110– Saúde, Mogi Mirim- SP.'
        address_width = pdf.width_of(address_text, size: 8)
        address_x = (page_width - address_width) / 2

        pdf.draw_text address_text, at: [address_x, footer_y - 12]
      end

      pdf.number_pages '<page> / <total>',
                       at: [page_width - 50, footer_y - 28],
                       width: 50,
                       align: :right,
                       size: 9
    end

    def content_area_bounding_box(_pdf, &)
      yield
    end
  end
end
