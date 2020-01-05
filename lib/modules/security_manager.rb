module SecurityManager
  module_function
  VAPID_PUBLIC_KEY  = ENV['VAPID_PUBLIC_KEY']
  VAPID_PRIVATE_KEY = ENV['VAPID_PRIVATE_KEY']

  def hash_digest(input)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(input, cost: cost)
  end

  def sha256(input)
    ::Digest::SHA256.hexdigest input
  end

  def public_vapid_key_bytes
    Base64.urlsafe_decode64(VAPID_PUBLIC_KEY).bytes
  end

  def md5(input)
    ::Digest::MD5.hexdigest input
  end
end
