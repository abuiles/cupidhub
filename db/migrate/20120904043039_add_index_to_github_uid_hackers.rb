class AddIndexToGithubUidHackers < ActiveRecord::Migration
  def change
    add_index :hackers, :github_uid, unique: true
  end
end
