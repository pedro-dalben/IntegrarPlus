class ChangeBeneficiaryIdToOptionalInAnamneses < ActiveRecord::Migration[8.0]
  def change
    change_column_null :anamneses, :beneficiary_id, true
  end
end
