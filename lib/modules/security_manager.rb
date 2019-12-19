module SecurityManager
  module_function
  def hash_digest(input)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(input, cost: cost)
  end

  def sha256(input)
    ::Digest::SHA256.hexdigest input
  end
end