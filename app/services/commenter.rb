# Print violation messages as comments on given GitHub pull request.
class Commenter
  pattr_initialize :pull_request

  def comment_on_violations(violations)
    violations.each do |violation|
      if commenting_policy.comment_on?(violation)
        pull_request.comment_on_violation(violation)
      end
    end
  end

  private

  def commenting_policy
    @_commenting_policy ||= CommentingPolicy.new(pull_request)
  end
end
