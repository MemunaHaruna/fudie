module ControllerSpecHelper
  def token_generator(user_id)
    Auth::JsonWebToken.encode(user_id: user_id)
  end

  def expired_token_generator(user_id)
    Auth::JsonWebToken.encode({ user_id: user_id }, (Time.now.to_i - 10))
  end

  def valid_headers(user_id)
    {
      "Authorization" => token_generator(user_id),
      "Content-Type" => "application/json",
    }
  end

  def invalid_headers
    {
      "Authorization" => nil,
      "Content-Type" => "application/json"
    }
  end

  def valid_post_params
    {
      title: "hello",
      state: 1,
      body: "random content"
    }
  end

  def invalid_post_params_1
    {
      title: nil,
      state: 0,
      body: "random content"
    }
  end

  def invalid_post_params_2
    {
      title: "whatever",
      state: 1,
      body: nil
    }
  end
end
