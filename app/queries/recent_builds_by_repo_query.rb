class RecentBuildsByRepoQuery
  NUMBER_OF_BUILDS = 20

  def self.run(*args)
    new(*args).run
  end

  def initialize(user:)
    @user = user
  end

  def run
    @user.builds.
      includes(:repo).
      from(Arel.sql("(#{ranked_by_created_at_subquery}) AS builds")).
      where("rank = 1").
      order("builds.created_at DESC").
      limit(NUMBER_OF_BUILDS)
  end

  private

  def ranked_by_created_at_subquery
    Build.select(<<-SQL).to_sql
      builds.*,
      dense_rank() OVER (
        PARTITION BY repo_id, pull_request_number
        ORDER BY created_at DESC
      ) AS rank
    SQL
  end
end
