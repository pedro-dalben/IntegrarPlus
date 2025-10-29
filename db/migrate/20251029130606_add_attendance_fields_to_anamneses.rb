class AddAttendanceFieldsToAnamneses < ActiveRecord::Migration[8.0]
  def change
    add_column :anamneses, :attendance_status, :string, default: 'scheduled'
    add_column :anamneses, :attended_at, :datetime
    add_column :anamneses, :no_show_at, :datetime
    add_column :anamneses, :cancelled_at, :datetime
    add_column :anamneses, :cancellation_reason, :text
    add_column :anamneses, :no_show_reason, :text

    add_index :anamneses, :attendance_status
  end
end
