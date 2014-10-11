# Print violation messages as comments on given GitHub pull request.
class Commenter
  pattr_initialize :pull_request

  def comment_on_violations(violations)
    violations.each do |violation|
      if commenting_policy.allowed_for?(violation)
        pull_request.comment_on_violation(violation)
      end
    end
  end

  def comment_on_commits
    pull_request.commits.each do |commit|
      violations = []

      if commit.subject.lines.length > 1
        violations << "Message subject consists of multiple lines."
      end

      if commit.subject.lines.any? { |line| line.length > 50 }
        violations << "Message subject line(s) exceeds 50 characters."
      end

      if commit.body.lines.any? { |line| line.length > 72 }
        violations << "Message body contains line(s) longer than 72 characters."
      end

      commit_commenting_policy = CommitCommentingPolicy.new(commit)
      violations.select! do |message|
        commit_commenting_policy.allowed_for?(message)
      end
      if violations.any?
        commit.add_comment(violations.join("\n"))
      end
    end
  end

  private

  def commenting_policy
    @commenting_policy ||= CommentingPolicy.new(pull_request)
  end
end
