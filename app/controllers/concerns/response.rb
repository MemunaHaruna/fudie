module Response
  def json_error_response(message: "error", status: :unprocessable_entity, errors: nil)
    render json: { message: message, errors: errors }, status: status
  end

  def json_auth_response(token: nil, message: 'success', status: :ok)
    render json: {token: token, message: message}, status: status
  end

  def json_response(message: 'Success', status: :ok, data: nil)
    render json: {message: message, data: data}, status: status
  end
end
