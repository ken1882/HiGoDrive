module SecurityManager
  module_function
  def hash_digest(input)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(input, cost: cost)
  end
end