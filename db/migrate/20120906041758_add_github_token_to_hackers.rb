class AddGithubTokenToHackers < ActiveRecord::Migration
  def change
    add_column :hackers, :github_token, :string
  end
end
