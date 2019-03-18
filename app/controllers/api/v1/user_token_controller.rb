class Api::V1::UserTokenController < Knock::AuthTokenController
  protect_from_forgery unless: -> { request.format.json? }

  def create
    knock_token = auth_token
    response.headers['Authorization'] = "Bearer #{knock_token.token}"
    render json: knock_token, status: :created
  end
end
