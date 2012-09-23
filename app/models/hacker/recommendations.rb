module Hacker::Recommendations
  def neo
    @neo ||= Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
  end

  def hacker_similarity(github_uid)
    starred_count = HackerSlurperJob.count_connections(self, 'starred')
    follows_count = HackerSlurperJob.count_connections(self, 'follows')

    response  = neo.execute_query(common_count_query(github_uid, 'starred'))
    common_repos = response["data"].flatten.first || 0

    response = neo.execute_query(common_count_query(github_uid, 'follows'))
    common_follows = response["data"].flatten.first || 0

    { starred_score:  ((common_repos/starred_count.to_f + 0.1) * 100).round(2),
      follows_score:  ((common_follows/follows_count.to_f + 0.1) * 100).round(2) }
  end

  def recommended_hackers
    response = neo.execute_query(recommended_hacker_query)
    return {} unless (response["data"].present? rescue false)

    # follows_count = HackerSlurperJob.count_connections(self, 'follows')

    recommendations = Hash.new{ |hsh, key| hsh[key] = {} }
    response["data"].each do |hacker, score, uid, url, avatar_url|
      # recommendations[hacker]["score"] = (score / follows_count.to_f).round(2) * 100
      recommendations[hacker]["score"] = score
      recommendations[hacker]["github_uid"] = uid
      recommendations[hacker]["url"] = url
      recommendations[hacker]["avatar_url"] = avatar_url
    end
    recommendations.delete(self.github_user)

    result = {}
    recommendations.each do |hacker, data|
      result[hacker] = data
      result[hacker]['similarity'] = hacker_similarity data['github_uid']
    end
    result.sort_by {|h,d| -[d['similarity'].values.max, d['score']].max }
  end

  def similar_hackers
    response = neo.execute_query(similiraty_query)
    return {} unless response["data"].present?

    starred_count = HackerSlurperJob.count_connections(self, 'starred')

    recommendations = Hash.new{ |hsh, key| hsh[key] = {} }
    response["data"].each do |hacker, score|
      recommendations[hacker]["simila"] = ((score / starred_count.to_f) * 100).round(2)
    end

    recommendations
  end

  def recommended_projects
    response = neo.execute_query(recommended_projects_query)
    return {} unless response["data"].present?

    recommendations = Hash.new{ |hsh, key| hsh[key] = {} }
    response["data"].each do |project, repo_id, url, score|
      recommendations[project]["repository_id"] = repo_id
      recommendations[project]["html_url"]      = url
      recommendations[project]["score"]         = score
    end

    recommendations
  end

  def recommended_hacker_query(limit = 50)
    %{
      START me=node:hackers(github_uid ='#{self.github_uid}')
      MATCH me-[:follows*2..2]-follow_of_follow
      WHERE not(me-[:follows]-follow_of_follow)
      RETURN follow_of_follow.github_user, COUNT(*), follow_of_follow.github_uid, follow_of_follow.url, follow_of_follow.avatar_url
      ORDER BY COUNT(*) DESC, follow_of_follow.github_user
      LIMIT #{limit}
    }
  end

  def similiraty_query(limit = 50)
    %{
       START me=node:hackers(github_uid ='#{self.github_uid}')
       MATCH me-[:follows*2..2]->follow_of_follow-[:starred]->repos
       WHERE (me-[:starred]->repos) AND not(me-[:follows]->follow_of_follow)
       RETURN follow_of_follow.github_user, count(repos)
       ORDER BY COUNT(repos) DESC, follow_of_follow.github_user
       SKIP 1 LIMIT #{limit}
    }
  end

  def recommended_projects_query(limit = 50)
    %{
      START me=node:hackers(github_uid = '#{self.github_uid}')
      MATCH me-[:follows]->follow-[:starred]->repo
      WHERE not(me-[:starred]->repo)
      RETURN repo.name as name, repo.repository_id as repository_id, repo.html_url as html_url, COUNT(repo.repository_id) as count
      ORDER BY COUNT(repo.repository_id) DESC
      LIMIT #{limit}
    }
  end

  def common_count_query(hacker_github_uid, relationship)
    %{
      START me=node:hackers(github_uid ='#{self.github_uid}')
      MATCH common=me-[:#{relationship}]->a<-[:#{relationship}]-hackers
      WHERE hackers.github_uid = #{hacker_github_uid}
      RETURN count(common) as count
    }
  end
end
