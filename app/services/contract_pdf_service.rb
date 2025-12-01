require 'prawn'
require 'prawn/table'

class ContractPdfService
  include PdfHeaderFooter

  def initialize(text_builder = ContractTextBuilder.new)
    @text_builder = text_builder
  end

  def generate_contract_pdf(contract)
    pdf = create_pdf_with_header_footer
    text = @text_builder.build_contract_text(contract)
    render_text_to_pdf(pdf, text)
    pdf
  end

  def generate_anexo_pdf(contract)
    return nil unless contract.job_role

    pdf = create_pdf_with_header_footer
    text = @text_builder.build_anexo_text(contract)
    render_text_to_pdf(pdf, text)
    pdf
  end

  def generate_termo_pdf(contract)
    pdf = create_pdf_with_header_footer
    text = @text_builder.build_termo_text(contract)
    render_text_to_pdf(pdf, text)
    pdf
  end

  def save_contract_pdf(contract)
    pdf = generate_contract_pdf(contract)
    path = save_pdf_to_storage(pdf, contract.professional_id, 'contract')
    contract.update(contract_pdf_path: path)
    path
  end

  def save_anexo_pdf(contract)
    pdf = generate_anexo_pdf(contract)
    return nil unless pdf

    path = save_pdf_to_storage(pdf, contract.professional_id, 'anexo')
    contract.update(anexo_pdf_path: path)
    path
  end

  def save_termo_pdf(contract)
    pdf = generate_termo_pdf(contract)
    path = save_pdf_to_storage(pdf, contract.professional_id, 'termo')
    contract.update(termo_pdf_path: path)
    path
  end

  private

  def render_text_to_pdf(pdf, text)
    pdf.font 'Helvetica'
    pdf.default_leading 1.5

    content_area_bounding_box(pdf) do
      # Ensure content starts well below the logo
      pdf.move_down 10

      paragraphs = split_into_paragraphs(text)

      paragraphs.each do |paragraph|
        next if paragraph.strip.empty?

        paragraph = paragraph.strip
        formatted = format_paragraph(paragraph)

        if paragraph.match?(/^\*\*CONTRATO/) || paragraph.match?(/^\*\*ANEXO/) || paragraph.match?(/^\*\*TERMO/)
          pdf.font_size 16
          pdf.text paragraph.gsub('**', ''), style: :bold, align: :center, leading: 2
          pdf.font_size 11
          pdf.move_down 18
        elsif paragraph.match?(/^\*\*DO\s[A-Z\s]+/)
          pdf.move_down 12
          pdf.font_size 13
          pdf.text formatted, inline_format: true, style: :bold, leading: 1.8
          pdf.font_size 11
          pdf.move_down 12
        elsif paragraph.match?(/^\*\*CONTRATANTE:\*\*/) || paragraph.match?(/^\*\*CONTRATADA/)
          pdf.font_size 12
          pdf.text formatted, inline_format: true, style: :bold, leading: 1.6
          pdf.font_size 11
          pdf.move_down 8
        elsif paragraph.match?(/^\*\*[A-Z][A-Z\s]+:\*\*/)
          pdf.font_size 12
          pdf.text formatted, inline_format: true, style: :bold, leading: 1.6
          pdf.font_size 11
          pdf.move_down 6
        elsif paragraph.match?(/^\*\*Cláusula\s+\d+[ªº]/)
          pdf.move_down 10
          pdf.font_size 12
          pdf.text formatted, inline_format: true, style: :bold, leading: 1.6
          pdf.font_size 11
          pdf.move_down 8
        elsif paragraph.match?(/^\*\*Parágrafo/)
          pdf.move_down 8
          pdf.font_size 11
          pdf.text formatted, inline_format: true, style: :bold, leading: 1.5
          pdf.move_down 6
        elsif paragraph.match?(/^[a-z]\)\s/)
          pdf.indent(25) do
            pdf.text formatted, inline_format: true, leading: 1.5
            pdf.move_down 4
          end
        elsif paragraph.match?(/^-\s/)
          lines = paragraph.split("\n")
          lines.each do |line|
            next unless line.strip.match?(/^-\s/)

            pdf.indent(25) do
              pdf.text "• #{format_bold_text(line.strip.sub(/^-\s/, ''))}", inline_format: true, leading: 1.4
            end
            pdf.move_down 4
          end
        elsif paragraph.match?(/^_{10,}/)
          pdf.move_down 18
          pdf.text paragraph, leading: 1
          pdf.move_down 10
        elsif paragraph.match?(/^(Mogi Mirim|Testemunhas?:)/)
          pdf.move_down 10
          pdf.font_size 11
          pdf.text formatted, inline_format: true, leading: 1.5
          pdf.move_down 6
        elsif paragraph.match?(/^(Nome:|RG|CPF)/)
          pdf.font_size 10
          pdf.text formatted, inline_format: true, style: :bold, leading: 1.4
          pdf.font_size 11
          pdf.move_down 4
        else
          pdf.text formatted, inline_format: true, leading: 1.5, align: :justify
          pdf.move_down 8
        end
      end
    end
  end

  def split_into_paragraphs(text)
    paragraphs = []
    current_paragraph = []

    text.split("\n").each do |line|
      line = line.strip

      if line.empty?
        if current_paragraph.any?
          paragraphs << current_paragraph.join("\n")
          current_paragraph = []
        end
      elsif line.match?(/^\*\*DO\s/) || line.match?(/^\*\*CONTRATO/) || line.match?(/^\*\*Cláusula/) ||
            line.match?(/^\*\*Parágrafo/) || line.match?(/^_{10,}/) || line.match?(/^(Mogi Mirim|Testemunhas?:)/)
        if current_paragraph.any?
          paragraphs << current_paragraph.join("\n")
          current_paragraph = []
        end
        paragraphs << line
      else
        current_paragraph << line
      end
    end

    paragraphs << current_paragraph.join("\n") if current_paragraph.any?
    paragraphs
  end

  def format_paragraph(text)
    formatted = format_bold_text(text)
    format_italic_text(formatted)
  end

  def format_bold_text(text)
    text.gsub(/\*\*(.+?)\*\*/m) { "<b>#{::Regexp.last_match(1).gsub("\n", ' ')}</b>" }
  end

  def format_italic_text(text)
    text.gsub(/_(.+?)_/) { "<i>#{::Regexp.last_match(1)}</i>" }
  end

  def save_pdf_to_storage(pdf, professional_id, document_type)
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    filename = "#{document_type}_#{timestamp}.pdf"
    directory = Rails.root.join('storage', 'contracts', professional_id.to_s)
    FileUtils.mkdir_p(directory)
    filepath = directory.join(filename)
    pdf.render_file(filepath)
    "contracts/#{professional_id}/#{filename}"
  end
end
