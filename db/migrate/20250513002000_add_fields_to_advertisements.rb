class AddFieldsToAdvertisements < ActiveRecord::Migration[7.2]
  def change
    add_column :advertisements, :ad_type, :string, null: false, default: 'image'
    add_column :advertisements, :ad_size, :string, null: false, default: 'square'
    add_column :advertisements, :alt_text, :string
  end
end 