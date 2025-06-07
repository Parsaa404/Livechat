module Api
  module V1
    class BaseController < Api::BaseController
      before_action :authenticate_user!
      before_action :set_account
    end
  end
end 