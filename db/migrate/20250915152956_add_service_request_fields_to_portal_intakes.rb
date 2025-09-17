class AddServiceRequestFieldsToPortalIntakes < ActiveRecord::Migration[8.0]
  def change
    add_column :portal_intakes, :convenio, :string
    add_column :portal_intakes, :carteira_codigo, :string
    add_column :portal_intakes, :nome, :string
    add_column :portal_intakes, :telefone_responsavel, :string
    add_column :portal_intakes, :data_encaminhamento, :date
    add_column :portal_intakes, :data_nascimento, :date
    add_column :portal_intakes, :endereco, :text
    add_column :portal_intakes, :responsavel, :string
    add_column :portal_intakes, :tipo_convenio, :string
    add_column :portal_intakes, :cpf, :string
  end
end
