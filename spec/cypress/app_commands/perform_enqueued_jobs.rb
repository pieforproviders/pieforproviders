# frozen_string_literal: true

ActiveJob::Base.queue_adapter = :good_job

Rails.logger.info 'RUNNING'

GoodJob::Job.all.map(&:perform)
ServiceDay.all.map(&:reload)
Child.all.map(&:reload)

Rails.logger.info 'DONE RUNNING'
