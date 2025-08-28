class AddFieldsToServiceRequestReferrals < ActiveRecord::Migration[8.0]
  def change
    add_column :service_request_referrals, :medico_crm, :string
    add_column :service_request_referrals, :data_encaminhamento, :date
  end
end
