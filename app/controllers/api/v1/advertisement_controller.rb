class Api::V1::AdvertisementController < Api::V1::BaseController
  def index
    @advertisements = Advertisement.all
    render json: @advertisements
  end
end
