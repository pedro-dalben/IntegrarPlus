# frozen_string_literal: true

class AddDataRecebimentoEmailToPortalIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :portal_intakes, :data_recebimento_email, :date
    add_index :portal_intakes, :data_recebimento_email
  end
end
