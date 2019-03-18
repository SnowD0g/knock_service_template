class User < ApplicationRecord
  has_secure_password

  def self.from_token_payload(payload)
    find(payload['sub'])
  end

  def to_token_payload
    {
        sub: id,
        email: email,
        type: type
    }
  end

  def super_admin?
    type == 'SuperAdmin'
  end

  def admin?
    type == 'Admin' || super_admin?
  end

  def operator?
    type == 'Operator' || admin?
  end
end
