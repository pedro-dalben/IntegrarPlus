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
