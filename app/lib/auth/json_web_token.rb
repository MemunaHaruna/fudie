module Auth
  class JsonWebToken
    JWT_SECRET = Rails.application.secrets.secret_key_base

    def self.encode(payload, expiry = 24.hours.from_now)
      payload[:expiry] = expiry.to_i
      JWT.encode(payload, JWT_SECRET)
    end

    def self.decode(token)
      payload = JWT.decode(token, JWT_SECRET)[0]
      HashWithIndifferentAccess.new payload

    rescue JWT::DecodeError => error
      raise ExceptionHandler::InvalidToken, error.message
    end
  end
end
