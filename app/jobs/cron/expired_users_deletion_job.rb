class Cron::ExpiredUsersDeletionJob < Cron::CronJob
  self.schedule_expression = Expired.schedule_at(self)

  def perform(*args)
    return if ENV['EXPIRE_USER_DELETION_JOB_LIMIT'].blank?
    Expired::UsersDeletionService.process_expired
  end
end
