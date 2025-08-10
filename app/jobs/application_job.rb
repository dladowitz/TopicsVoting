# Base class for all background jobs in the application
# @abstract Subclass and add your own functionality
class ApplicationJob < ActiveJob::Base
  # Automatically retry failed jobs
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
