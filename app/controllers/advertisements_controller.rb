# frozen_string_literal: true

class AdvertisementsController < ApplicationController
  before_action :set_advertisement, only: [:show, :edit, :update, :destroy]

  # GET /advertisements
  def index
    @q = Advertisement.ransack(params[:q])
    per_page = params[:per_page]&.to_i || 20
    per_page = [per_page, 100].min # 最大100件まで
    @advertisements = @q.result(distinct: true).order(created_at: :desc).page(params[:page]).per(per_page)
  end

  # GET /advertisements/:id
  def show
  end

  # GET /advertisements/new
  def new
    @advertisement = Advertisement.new
  end

  # POST /advertisements
  def create
    @advertisement = Advertisement.new(advertisement_params)

    if @advertisement.save
      redirect_to @advertisement, notice: '広告が正常に作成されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /advertisements/:id/edit
  def edit
  end

  # PATCH/PUT /advertisements/:id
  def update
    if @advertisement.update(advertisement_params)
      redirect_to @advertisement, notice: '広告が正常に更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /advertisements/:id
  def destroy
    @advertisement.destroy
    redirect_to advertisements_url, notice: '広告が正常に削除されました。'
  end

  private

  def set_advertisement
    @advertisement = Advertisement.find(params[:id])
  end

  def advertisement_params
    params.require(:advertisement).permit(
      :title,
      :link_url,
      :image_url,
      :ad_type,
      :ad_size,
      :alt_text,
      :active,
      :tag_list
    )
  end
end 