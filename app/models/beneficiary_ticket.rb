# frozen_string_literal: true

class BeneficiaryTicket < ApplicationRecord
  belongs_to :beneficiary
  belongs_to :assigned_professional, class_name: 'Professional', optional: true
  belongs_to :created_by, class_name: 'User'

  enum :status, { open: 0, in_progress: 1, resolved: 2, closed: 3 }

  validates :title, presence: true, length: { maximum: 255 }

  after_create_commit do
    NotificationService.send_ticket_created_notification(self)
    NotificationService.send_ticket_assigned_notification(self) if assigned_professional_id.present?
  end

  after_update_commit do
    if saved_change_to_status?
      NotificationService.send_ticket_status_changed_notification(self, status_before_last_save, created_by)
    end

    if saved_change_to_assigned_professional_id? && assigned_professional_id.present?
      NotificationService.send_ticket_assigned_notification(self)
    end
  end
end
