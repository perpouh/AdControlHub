# frozen_string_literal: true

# == Schema Information
#
# Table name: advertisements
#
#  id         :bigint           not null, primary key
#  title      :string(255)
#  link_url   :string(255)
#  image_url  :string(255)
#  active     :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Advertisement < ApplicationRecord
  validates :title, presence: true
  validates :link_url, presence: true
  validates :image_url, presence: false
  validates :active, inclusion: { in: [true, false] }
  before_save :set_tags
  after_save :register_tags

  def set_tags
    if @tag_string.present?
      self.tags = @tag_string.split(',').map(&:strip).uniq
    else
      self.tags = []
    end
  end

  def register_tags
    (tags || []).each do |tag_name|
      Tag.find_or_create_by(name: tag_name)
    end
  end

  def tag_string
    tags&.join(', ')
  end

  def tag_string=(value)
    @tag_string = value
  end
end
