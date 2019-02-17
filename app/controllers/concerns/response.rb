module Response
  def json_error_response(message: "error", status: :unprocessable_entity)
    render json: { message: message }, status: status
  end

  def json_auth_response(token: nil, message: 'success', status: :ok)
    render json: {token: token, message: message}, status: status
  end
end
