module Agent
  class User < ApplicationRecord
    include Agent::User::Registerable

    has_secure_password
    has_person_name

    has_many :assistants, -> { not_deleted }
    has_many :assistants_including_deleted, class_name: "Agent::Assistant", inverse_of: :user, dependent: :destroy
    has_many :conversations, dependent: :destroy
    has_many :clients, dependent: :destroy
    has_many :memories, dependent: :destroy

    belongs_to :last_cancelled_message, class_name: "Agent::Message", optional: true

    validates :first_name, presence: true
    validates :email, presence: true, uniqueness: true,
      format: { with: URI::MailTo::EMAIL_REGEXP }

    encrypts :email, deterministic: true
    normalizes :email, with: -> email { email.downcase.strip }

    serialize :preferences, coder: JsonSerializer

    def preferences
      attributes["preferences"].with_defaults(dark_mode: "system")
    end
  end
end
