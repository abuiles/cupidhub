class Hacker < ActiveRecord::Base
  include Hacker::Recommendations

  attr_accessible :github_user, :name, :github_token, :email, :image_url, :github_uid

  after_create :populate_neo4j

  def followings(options = { per_page: 50 })
    github.users.followers.following(github_user, options)
  end

  def recommendations
    @recommendations ||= generate_recommendations
  end

  def matches(hackers)
    matches = {}
    hackers.each do |h|
      hacker = Hacker.new github_user: h.login
      matches[h] = match hacker
    end
    matches
  end

  def match(hacker)
    common_repos = hacker.taste & taste
    common_repos.length / taste.length.to_f * 100
  end

  def taste
    @taste ||= watched.map(&:name)
  end

  def watched(options = { per_page: 50 })
    github.repos.watching.watched(options.merge(user: github_user))
  end

  def populate_neo4j
    puts "I should start populating neo4j"
  end
  private

  def generate_recommendations
    followings.each do |f|
      hacker = Hacker.new github_user: f.login

    end
  end

  def github
    @github ||= Github.new oauth_token: github_token
  end
end
