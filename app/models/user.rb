class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Roles
  ROLES = %w[admin moderator participant].freeze

  validates :role, inclusion: { in: ROLES }, presence: true

  # Set default role before creation
  before_validation :set_default_role, on: :create

  def admin?
    role == "admin"
  end

  def moderator?
    role == "moderator"
  end

  def participant?
    role == "participant"
  end

  private

  def set_default_role
    self.role ||= "participant"
  end
end
