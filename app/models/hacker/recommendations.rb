module Hacker::Recommendations
  def neo
    @neo ||= Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
  end

  def recommended_hackers
    response = neo.execute_query(recommended_hacker_query)
    return {} unless response["data"].present?

    recommendations = Hash.new{ |hsh, key| hsh[key] = {} }
    response["data"].each do |hacker, score|
      recommendations[hacker]["score"] = score
    end
    recommendations.delete(self.github_user)

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
      RETURN follow_of_follow.github_user, COUNT(*)
      ORDER BY COUNT(*) DESC, follow_of_follow.github_user
      LIMIT #{limit}
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
end
