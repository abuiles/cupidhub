class AddGithubUidToHackers < ActiveRecord::Migration
  def change
    add_column :hackers, :github_uid, :integer
  end
end
