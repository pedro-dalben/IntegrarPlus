class AddAddressFieldsToServiceRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :service_requests, :rua, :string
    add_column :service_requests, :numero, :string
    add_column :service_requests, :bairro, :string
    add_column :service_requests, :cidade, :string
    add_column :service_requests, :cep, :string
  end
end
