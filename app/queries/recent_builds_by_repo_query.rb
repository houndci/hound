class RecentBuildsByRepoQuery
  NUMBER_OF_BUILDS = 20

  def self.run(*args)
    new(*args).run
  end

  def initialize(user:)
    @user = user
  end

  def run
    Build.find_by_sql([<<-SQL, user_id: @user.id, limit: NUMBER_OF_BUILDS])
      WITH user_builds AS (
        SELECT
          builds.id
        FROM
          builds
          INNER JOIN repos
            ON builds.repo_id = repos.id
          INNER JOIN memberships
            ON repos.id = memberships.repo_id
        WHERE
          memberships.user_id = :user_id
      ),
      recent_builds_by_pull_request AS (
        SELECT distinct ON (repo_id, pull_request_number)
          builds.*
        FROM
          builds
          INNER JOIN user_builds
            ON user_builds.id = builds.id
        ORDER BY
          repo_id,
          pull_request_number,
          created_at DESC,
          id DESC
      )
      SELECT
        *
      FROM
        recent_builds_by_pull_request
      ORDER BY
        created_at DESC
      LIMIT
        :limit
    SQL
  end
end
