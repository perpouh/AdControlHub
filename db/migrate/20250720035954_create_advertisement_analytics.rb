class CreateAdvertisementAnalytics < ActiveRecord::Migration[7.2]
  def change
    create_table :advertisement_analytics do |t|
      t.string :advertisement_id
      t.datetime :target_date
      t.string :search_word
      t.integer :click_count
      t.datetime :archived_at, null: true

      t.timestamp :created_at, default: -> { '(CURRENT_TIMESTAMP)' }
      t.timestamp :updated_at, default: -> { '(CURRENT_TIMESTAMP)' }
    end
  end
end
