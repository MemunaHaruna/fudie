module Auth
  class AuthorizeApiRequest
    attr_reader :headers

    def initialize(headers = {})
      @headers = headers
    end

    def call
      { user: user }
    end

    def user
      @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
    rescue ActiveRecord::RecordNotFound
      raise ExceptionHandler::InvalidToken, 'Invalid Token'
    end

    def decoded_auth_token
      @decoded_auth_token ||= Auth::JsonWebToken.decode(http_auth_header)
    end

    def http_auth_header
      if headers["Authorization"].present?
        return headers["Authorization"].split(" ").last
      end

      raise ExceptionHandler::MissingToken, 'Missing Token'
    end
  end
end
