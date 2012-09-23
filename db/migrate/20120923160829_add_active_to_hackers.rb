class AddActiveToHackers < ActiveRecord::Migration
  def change
    add_column :hackers, :active, :boolean, default: false
  end
end
