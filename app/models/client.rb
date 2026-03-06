class Client < ApplicationRecord
  belongs_to :user

  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :authenticated, -> { not_deleted }
  enum :platform, %w[ ios android web api ].index_by(&:to_sym)

  has_secure_token

  scope :ordered, -> { order(updated_at: :asc) }

  def authenticated?
    deleted_at.nil?
  end

  def logout!
    update!(deleted_at: Time.current)
    true
  end

  def bearer_token
    return nil unless api?
    "#{id}:#{token}"
  end

  def to_s
    token
  end
end
