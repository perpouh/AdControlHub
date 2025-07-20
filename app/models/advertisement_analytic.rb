# frozen_string_literal: true

# == Schema Information
#
# Table name: advertisement_analytics
#
#  id              :bigint           not null, primary key
#  advertisement_id :string
#  target_date      :datetime
#  search_word      :string
#  click_count      :integer
#  archived_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class AdvertisementAnalytic < ApplicationRecord
  belongs_to :advertisement
end
