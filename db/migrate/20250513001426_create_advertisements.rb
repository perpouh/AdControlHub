class CreateAdvertisements < ActiveRecord::Migration[7.2]
  def change
    create_table :advertisements do |t|
      t.string :title, null: false
      t.string :link_url, null: false
      t.string :image_url
      t.boolean :active, default: false
      t.string :tags, array: true, default: []

      t.timestamps
    end
  end
end
