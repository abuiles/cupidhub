class HackerSlurperJob
  def self.neo
    @neo ||= Neography::Rest.new(ENV['NEO4J_URL'] || "http://localhost:7474")
  end
  #
  # Creates hacker in neo4j
  # Add followings to neo4j and add relationship of type :follows
  # :hacker --- follows ---> :follow
  # For each of the follows add the ones they follow and create relationship too.
  # Add starred repositories to neo4j
  # :hacker -- starred ----> :repository
  # Add follows starred repositories
  #
  def self.perform(github_uid)
    hacker = Hacker.where(github_uid: github_uid).first
    create_hacker_node(hacker)

    migrate_followers(hacker)
    migrate_starred(hacker)

    hacker.followings.each_page do |page|
      page.each do |follow|
        follow.github_uid = follow.id

        next if count_connections(follow) > 0

        follow = Hacker.new(github_user: follow.login, github_uid: follow.github_uid)
        migrate_followers(follow)
        migrate_starred(follow)
      end
    end

    hacker.active = true
    hacker.save
  end

  def self.migrate_followers(hacker)
    hacker.followings.each_page do |page|
      page.each do |follow|
        follow = Hacker.new(github_user: follow.login, github_uid: follow.id)
        create_hacker_node(follow)
        create_following(from = hacker, to = follow)
      end
    end
  end

  def self.migrate_starred(hacker)
    hacker.watched.each_page do |page|
      page.each do |repository|
        create_repository(repository)
        create_starred(from = hacker, to = repository)
      end
    end
  end

  def self.create_hacker_node(hacker)
    node = find_user_by_github_uid(hacker.github_uid)
    return node.first if node.present?

    node = neo.create_node(
      github_user: hacker.github_user,
      github_uid: hacker.github_uid
    )

    neo.add_node_to_index("hackers", "github_uid", hacker.github_uid, node)
    node
  end

  def self.create_repository(repository)
    node = find_repo_by_github_id(repository.id)
    return node.first if node.present?

    node = neo.create_node(
      html_url: repository.html_url,
      name: repository.name,
      full_name: repository.full,
      repository_id: repository.id,
    )

    neo.add_node_to_index("repos", "id", repository.id, node)
    node
  end

  def self.create_following(from, to)
    # puts "Creating follows #{from.github_user}-[:follows]->#{to.github_user}"
    from = find_user_by_github_uid(from.github_uid)
    to   = find_user_by_github_uid(to.github_uid)
    raise "Hacker#{from.inspect} not found in create_following" unless from
    raise "Hacker#{to.inspect} not found in create_following" unless to

    from = Neography::Node.load(from)
    to   = Neography::Node.load(to)

    neo.create_unique_relationship(
      "follows_index",
      "github_id",
      "#{from.github_uid}.#{to.github_uid}",
      "follows",
      from,
      to
    )
  end

  def self.create_starred(from, to)
    from = find_user_by_github_uid(from.github_uid)
    to   = find_repo_by_github_id(to.id)
    raise "user#{from.inspect} not found in create_starred" unless from
    raise "repo#{to.inspect} not found in create_starred" unless to

    from = Neography::Node.load(from)
    to   = Neography::Node.load(to)


    neo.create_unique_relationship(
      "starred_index",
      "name",
      "#{from.github_uid}.#{to.repository_id}",
      "starred",
      from,
      to
    )
  end

  def self.find_user_by_github_uid(github_uid)
    neo.find_node_index("hackers", "github_uid", github_uid).try(:first)
  end

  def self.find_repo_by_github_id(uid)
    neo.find_node_index("repos", "id", uid).try(:first)
  end

  def self.count_connections(hacker, type = nil)
    if type.present?
      q =  "START me=node:hackers(github_uid = '#{hacker.github_uid}') MATCH me-[:#{type}]->(x) RETURN COUNT(x)"
    else
      q =  "START me=node:hackers(github_uid = '#{hacker.github_uid}') MATCH me-->(x) RETURN COUNT(x)"
    end
    response = neo.execute_query(q)
    response["data"].flatten.first || 0
  end
end
