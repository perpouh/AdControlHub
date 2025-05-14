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
  # has_one_attached :image
  attr_accessor :tag_string
end
