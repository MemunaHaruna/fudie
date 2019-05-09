module Response
  def json_error_response(message: "error", status: :unprocessable_entity, errors: nil)
    render json: { message: message, errors: errors }, status: status
  end

  def json_auth_response(token: nil, message: 'success', status: :ok)
    render json: {token: token, message: message}, status: status
  end

  def json_response(message: 'Success', status: :ok, data: nil, show_children: true)
    if data.respond_to? :size
      return render json: data, show_children: show_children,
             meta: {
               message: message,
               pagination: pagination_dict(data)
             }, status: status
    end
    render json: data, show_children: show_children,
             meta: message, meta_key: :message, status: status
  end

  def json_basic_response(message: 'Success', status: :ok)
    render json: { message: message, errors: nil }, status: status
  end
end
