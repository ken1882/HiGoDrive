class WebpushClient
  def self.public_key
    SecurityManager::VAPID_PUBLIC_KEY
  end

  def self.public_key_bytes
    SecurityManager.public_vapid_key_bytes
  end

  def self.private_key
    SecurityManager::VAPID_PRIVATE_KEY
  end

  # Send webpush message using subscription parameters
  #
  # @param message [String] text to encrypt
  # @param subscription_params [Hash<Symbol, String>]
  # @option subscription_params [String] :endpoint url to send encrypted message
  # @option subscription_params [Hash<Symbol, String>] :keys auth keys to send with message for decryption
  # @return true/false
  def send_notification(message, endpoint: "", p256dh: "", auth: "")
    raise ArgumentError, ":endpoint param is required" if endpoint.blank?
    raise ArgumentError, "subscription :keys are missing" if p256dh.blank? || auth.blank?

    Rails.logger.info("Sending WebPush notification...............")
    Rails.logger.info("message: #{message}")
    Rails.logger.info("endpoint: #{endpoint}")
    Rails.logger.info("p256dh: #{p256dh}")
    Rails.logger.info("auth: #{auth}")
    
    Webpush.payload_send \
      message: message.to_json,
      endpoint: endpoint,
      p256dh: p256dh,
      auth: auth,
      vapid: {
        subject: "mailto:006571121@email.ntou.edu.tw",
        public_key: public_key,
        private_key: private_key,
        expiration: 60 * 60 * 12
      }
  end

  def public_key
    self.class.public_key
  end

  def private_key
    self.class.private_key
  end
end
