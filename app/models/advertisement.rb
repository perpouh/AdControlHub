# frozen_string_literal: true

# == Schema Information
#
# Table name: advertisements
#
#  id         :bigint           not null, primary key
#  title      :string(255)      not null
#  link_url   :string(255)      not null
#  image_url  :string(255)
#  active     :boolean          default(FALSE)
#  tags       :string[]         default([])
#  ad_type    :string           not null, default("image")
#  ad_size    :string           not null, default("square")
#  alt_text   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Advertisement < ApplicationRecord
  # 広告種別のenum定義
  enum ad_type: {
    image: 'image',
    video: 'video'
  }, _prefix: true

  # 広告サイズのenum定義
  enum ad_size: {
    vertical: 'vertical',    # 縦長
    horizontal: 'horizontal', # 横長
    square: 'square'         # 正方形
  }, _prefix: true

  # バリデーション
  validates :title, presence: true, length: { maximum: 255 }
  validates :link_url, presence: true, format: { with: /\Ahttps?:\/\/.+\z/, message: 'は有効なURL形式である必要があります' }
  validates :image_url, format: { with: /\Ahttps?:\/\/.+\z/, message: 'は有効なURL形式である必要があります' }, allow_blank: true
  validates :ad_type, presence: true, inclusion: { in: ad_types.keys }
  validates :ad_size, presence: true, inclusion: { in: ad_sizes.keys }

  # スコープ
  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(ad_type: type) }
  scope :by_size, ->(size) { where(ad_size: size) }

  # インスタンスメソッド
  def tag_list
    tags.join(', ')
  end

  def tag_list=(value)
    self.tags = value.to_s.split(',').map(&:strip).reject(&:blank?)
  end

  def tags=(value)
    if value.is_a?(String)
      # 文字列の場合は配列に変換
      super(value.split(',').map(&:strip).reject(&:blank?))
    else
      # 配列の場合は空文字列を除去
      super(value.reject(&:blank?).map(&:to_s))
    end
  end

  def display_name
    "#{title} (#{ad_type.humanize} - #{ad_size.humanize})"
  end

  def image?
    ad_type == 'image'
  end

  def video?
    ad_type == 'video'
  end

  def vertical?
    ad_size == 'vertical'
  end

  def horizontal?
    ad_size == 'horizontal'
  end

  def square?
    ad_size == 'square'
  end


end
