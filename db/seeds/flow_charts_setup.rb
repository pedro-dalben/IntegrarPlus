# frozen_string_literal: true

Rails.logger.debug '📊 Configurando Fluxogramas de exemplo...'

admin_professional = Professional.find_by(email: 'admin@integrarplus.com')

if admin_professional.present?
  sample_diagram_xml = <<~XML
    <mxfile host="embed.diagrams.net" modified="2024-10-21T00:00:00.000Z" agent="IntegrarPlus" version="1.0.0" etag="" type="embed">
      <diagram name="Processo de Atendimento" id="sample-1">
        <mxGraphModel dx="800" dy="600" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="827" pageHeight="1169" math="0" shadow="0">
          <root>
            <mxCell id="0"/>
            <mxCell id="1" parent="0"/>
            <mxCell id="2" value="Início" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
              <mxGeometry x="364" y="40" width="100" height="40" as="geometry"/>
            </mxCell>
            <mxCell id="3" value="Receber Solicitação" style="rounded=0;whiteSpace=wrap;html=1;" vertex="1" parent="1">
              <mxGeometry x="354" y="120" width="120" height="60" as="geometry"/>
            </mxCell>
            <mxCell id="4" value="Avaliar Solicitação" style="rhombus;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;" vertex="1" parent="1">
              <mxGeometry x="344" y="220" width="140" height="80" as="geometry"/>
            </mxCell>
            <mxCell id="5" value="Aprovar" style="rounded=0;whiteSpace=wrap;html=1;" vertex="1" parent="1">
              <mxGeometry x="254" y="350" width="100" height="60" as="geometry"/>
            </mxCell>
            <mxCell id="6" value="Rejeitar" style="rounded=0;whiteSpace=wrap;html=1;" vertex="1" parent="1">
              <mxGeometry x="474" y="350" width="100" height="60" as="geometry"/>
            </mxCell>
            <mxCell id="7" value="Fim" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#f8cecc;strokeColor=#b85450;" vertex="1" parent="1">
              <mxGeometry x="364" y="460" width="100" height="40" as="geometry"/>
            </mxCell>
            <mxCell id="8" value="" style="endArrow=classic;html=1;rounded=0;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;" edge="1" parent="1" source="2" target="3">
              <mxGeometry width="50" height="50" relative="1" as="geometry">
                <mxPoint x="384" y="300" as="sourcePoint"/>
                <mxPoint x="434" y="250" as="targetPoint"/>
              </mxGeometry>
            </mxCell>
            <mxCell id="9" value="" style="endArrow=classic;html=1;rounded=0;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;" edge="1" parent="1" source="3" target="4">
              <mxGeometry width="50" height="50" relative="1" as="geometry">
                <mxPoint x="384" y="300" as="sourcePoint"/>
                <mxPoint x="434" y="250" as="targetPoint"/>
              </mxGeometry>
            </mxCell>
            <mxCell id="10" value="Sim" style="endArrow=classic;html=1;rounded=0;exitX=0;exitY=0.5;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;" edge="1" parent="1" source="4" target="5">
              <mxGeometry width="50" height="50" relative="1" as="geometry">
                <mxPoint x="384" y="300" as="sourcePoint"/>
                <mxPoint x="434" y="250" as="targetPoint"/>
              </mxGeometry>
            </mxCell>
            <mxCell id="11" value="Não" style="endArrow=classic;html=1;rounded=0;exitX=1;exitY=0.5;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;" edge="1" parent="1" source="4" target="6">
              <mxGeometry width="50" height="50" relative="1" as="geometry">
                <mxPoint x="384" y="300" as="sourcePoint"/>
                <mxPoint x="434" y="250" as="targetPoint"/>
              </mxGeometry>
            </mxCell>
            <mxCell id="12" value="" style="endArrow=classic;html=1;rounded=0;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;" edge="1" parent="1" source="5" target="7">
              <mxGeometry width="50" height="50" relative="1" as="geometry">
                <mxPoint x="384" y="300" as="sourcePoint"/>
                <mxPoint x="434" y="250" as="targetPoint"/>
              </mxGeometry>
            </mxCell>
            <mxCell id="13" value="" style="endArrow=classic;html=1;rounded=0;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=1;entryY=0.5;entryDx=0;entryDy=0;" edge="1" parent="1" source="6" target="7">
              <mxGeometry width="50" height="50" relative="1" as="geometry">
                <mxPoint x="384" y="300" as="sourcePoint"/>
                <mxPoint x="434" y="250" as="targetPoint"/>
              </mxGeometry>
            </mxCell>
          </root>
        </mxGraphModel>
      </diagram>
    </mxfile>
  XML

  flow_chart = FlowChart.find_or_create_by(
    title: 'Processo de Atendimento Padrão',
    created_by: admin_professional
  ) do |fc|
    fc.description = 'Fluxograma exemplo mostrando o processo padrão de atendimento de solicitações'
    fc.status = :draft
    fc.updated_by = admin_professional
  end

  if flow_chart.versions.empty?
    version = flow_chart.versions.create!(
      data: sample_diagram_xml,
      data_format: :xml,
      notes: 'Versão inicial do fluxograma de exemplo',
      created_by: admin_professional
    )

    flow_chart.update!(current_version: version, status: :published)
    Rails.logger.debug '✅ Fluxograma de exemplo criado com sucesso'
  else
    Rails.logger.debug '✅ Fluxograma de exemplo já existe'
  end

  draft_flow_chart = FlowChart.find_or_create_by!(
    title: 'Fluxograma em Desenvolvimento',
    created_by: admin_professional
  ) do |fc|
    fc.description = 'Este é um fluxograma em desenvolvimento que ainda não foi publicado'
    fc.status = :draft
    fc.updated_by = admin_professional
  end

  if draft_flow_chart.versions.empty?
    Rails.logger.debug '✅ Fluxograma rascunho criado (sem versões)'
  else
    Rails.logger.debug '✅ Fluxograma rascunho já existe'
  end
else
  Rails.logger.warn '⚠️  Profissional admin não encontrado. Pulando criação de fluxogramas de exemplo.'
end

Rails.logger.debug '📊 Configuração de fluxogramas concluída!'
