# Base class for all models in the application
# @abstract Subclass and add your own functionality
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
