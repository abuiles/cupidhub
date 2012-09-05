class HackerSlurperJob
  def self.neo
    @neo ||= Neography::Rest.new("http://localhost:7474")
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

    hacker.followings.each do |follow|
      follow = Hacker.new(github_user: follow.login)

      migrate_followers(follow)
      migrate_starred(follow)
    end
  end

  def self.migrate_followers(hacker)
    hacker.followings.each do |follow|
      follow = Hacker.new(github_user: follow.login)
      create_hacker_node(follow)
      create_following(from = hacker, to = follow)
    end
  end

  def self.migrate_starred(hacker)
    hacker.watched.each do |repository|
      create_repository(repository)
      create_starred(from = hacker, to = repository)
    end
  end

  def self.create_hacker_node(hacker)
    node = find_user_by_github_user(hacker.github_user)
    return node.first if node.present?

    node = neo.create_node(
      github_user: hacker.github_user,
      github_uid: hacker.github_uid
    )

    neo.add_node_to_index('hackers', 'github_user', hacker.github_user, node)
    node
  end

  def self.create_repository(repository)
    node = find_repo_by_name(repository.name)
    return node.first if node.present?

    node = neo.create_node(
      html_url: repository.html_url,
      name: repository.name,
      repository_id: repository.id
    )

    neo.add_node_to_index('repos', 'name', repository.name, node)
    node
  end

  def self.create_following(from, to)
    from = find_user_by_github_user(from.github_user)
    to   = find_user_by_github_user(to.github_user)
    raise 'Hacker not found in create_following' unless from && to

    from = Neography::Node.load(from)
    to   = Neography::Node.load(to)

    neo.create_unique_relationship(
      'follows_index',
      'name',
      "#{from.github_user}.#{to.github_user}",
      "follows",
      from,
      to
    )
  end

  def self.create_starred(from, to)
    from = find_user_by_github_user(from.github_user)
    to   = find_repo_by_name(to.name)
    raise 'repo  not found in create_starred' unless from && to

    from = Neography::Node.load(from)
    to   = Neography::Node.load(to)


    neo.create_unique_relationship(
      'starred_index',
      'name',
      "#{from.github_user}.#{to.name}",
      'starred',
      from,
      to
    )
  end

  def self.find_user_by_github_user(github_user)
    neo.find_node_index('hackers', 'github_user', github_user).try(:first)
  end

  def self.find_repo_by_name(name)
    neo.find_node_index('repos', 'name', name).try(:first)
  end
end
