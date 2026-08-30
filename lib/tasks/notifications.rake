namespace :notifications do
  desc "Check plan statuses (expiring and expired) and send notifications"
  task check_plan_statuses: :environment do
    puts "Checking plan statuses (expiring and expired)..."
    CheckPlanStatusesJob.perform_now
    puts "Done!"
  end

  desc "Enqueue plan status check job (for testing recurring tasks)"
  task enqueue_check_plan_statuses: :environment do
    puts "Enqueuing plan status check job..."
    CheckPlanStatusesJob.perform_later
    puts "Job enqueued! Check Mission Control at http://localhost:3000/admin/jobs"
  end
end
