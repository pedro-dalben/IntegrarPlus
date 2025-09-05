# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

# Daily reminder job - runs every day at 8:00 AM
every 1.day, at: '8:00 am' do
  runner "DailyReminderJob.perform_later"
end

# Weekly reminder job - runs every Monday at 8:00 AM
every 1.week, at: '8:00 am' do
  runner "WeeklyReminderJob.perform_later"
end

# Check for emergency appointments every 30 minutes
every 30.minutes do
  runner "MedicalAppointmentService.check_emergency_appointments"
end

# Check for overdue appointments every hour
every 1.hour do
  runner "MedicalAppointmentService.check_overdue_appointments"
end

# Process scheduled notifications every 5 minutes
every 5.minutes do
  runner "ScheduledNotificationJob.perform_later"
end

# Send daily reports at 8:00 AM
every 1.day, at: '8:00 am' do
  runner "MedicalAppointmentService.send_daily_schedules"
end

# Send weekly summary on Mondays at 9:00 AM
every 1.week, at: '9:00 am' do
  runner "AgendaAlertService.send_weekly_summary"
end

# Cleanup old notifications weekly on Sundays at 2:00 AM
every 1.week, at: '2:00 am' do
  runner "NotificationCleanupJob.perform_later"
end
