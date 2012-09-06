class AddEmailAndImageUrlToHackers < ActiveRecord::Migration
  def change
    add_column :hackers, :email, :string
    add_column :hackers, :image_url, :string
  end
end
