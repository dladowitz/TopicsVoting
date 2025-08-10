# Base class for all mailers in the application
# @abstract Subclass and add your own functionality
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
end
