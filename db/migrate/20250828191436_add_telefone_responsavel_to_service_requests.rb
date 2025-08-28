class AddTelefoneResponsavelToServiceRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :service_requests, :telefone_responsavel, :string
  end
end
