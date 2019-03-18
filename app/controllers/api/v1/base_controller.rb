class Api::V1::BaseController < ApplicationController
  include Knock::Authenticable
  include Permission
  before_action :authenticate_user
end
