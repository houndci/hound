# Print violation messages as comments on given GitHub pull request.
class Commenter
  pattr_initialize :commit

  def comment_on_violations(violations)
    violations.each do |violation|
      if commenting_policy.allowed_for?(violation)
        commit.add_comment(violation)
      end
    end
  end

  private

  def commenting_policy
    @commenting_policy ||= CommentingPolicy.new(commit)
  end
end
