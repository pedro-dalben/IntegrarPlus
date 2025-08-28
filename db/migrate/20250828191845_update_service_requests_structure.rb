class UpdateServiceRequestsStructure < ActiveRecord::Migration[8.0]
  def change
    # Remove colunas que não são mais usadas
    remove_column :service_requests, :cpf, :string
    remove_column :service_requests, :data_nascimento, :date
    remove_column :service_requests, :endereco, :text
    remove_column :service_requests, :rua, :string
    remove_column :service_requests, :numero, :string
    remove_column :service_requests, :bairro, :string
    remove_column :service_requests, :cidade, :string
    remove_column :service_requests, :cep, :string

    # Remove coluna responsável (não é mais usada no formulário)
    remove_column :service_requests, :responsavel, :string

    # Preenche valores nulos antes de tornar NOT NULL
    execute "UPDATE service_requests SET telefone_responsavel = '(00) 00000-0000' WHERE telefone_responsavel IS NULL"

    # Adiciona validação NOT NULL para telefone_responsavel
    change_column_null :service_requests, :telefone_responsavel, false
  end
end
