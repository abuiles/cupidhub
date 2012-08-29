class Hacker < ActiveRecord::Base
  attr_accessible :github_user, :name

  def followings
    @followings ||= github.users.followers.following github_user
    @matches ||= matches @followings
    puts @matches
    @matches
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

  def watched
    @watched ||= github.repos.watching.watched user: github_user
  end

  private

  def generate_recommendations
    followings.each do |f|
      hacker = Hacker.new github_user: f.login

    end
  end

  def github
    @github ||= Github.new
  end
end
