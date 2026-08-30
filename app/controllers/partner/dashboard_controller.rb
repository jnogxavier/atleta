module Partner
  class DashboardController < ApplicationController
    include PartnerAuthorization

    def index
      @profile = current_user.partner_profile
    end
  end
end
