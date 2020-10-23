class AccessToken < ApplicationRecord
  after_initialize :generate_token

  belongs_to :user

  validates :token, presence: true
  validates :user, presence: true
  validates_associated :user

  private

  def generate_token
    loop do
      break if token.present? && !AccessToken.exists?(token: token)

      self.token = SecureRandom.hex(10)
    end
  end
end
