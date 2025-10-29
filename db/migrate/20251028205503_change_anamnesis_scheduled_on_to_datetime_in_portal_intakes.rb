class ChangeAnamnesisScheduledOnToDatetimeInPortalIntakes < ActiveRecord::Migration[8.0]
  def change
    change_column :portal_intakes, :anamnesis_scheduled_on, :datetime
  end
end
