class BuildRunner
  attr_reader :guide

  def initialize
    @guide = StyleGuide.new(
      [
        BraceRule.new,
        BracketRule.new,
        MethodParenRule.new,
        ParenRule.new,
        QuoteRule.new,
        WhitespaceRule.new
      ]
    )
  end

  def run(commit, github_api)
    github_api.create_pending_status(commit, 'Hound is working...')

    patch = github_api.patch(commit)
    diff = GitDiff.new(patch)
    guide.check(diff.additions)

    if guide.violations.any?
      github_api.create_failure_status(commit, 'Hound does not approve')
    else
      github_api.create_successful_status(commit, 'Hound approves')
    end
  end
end
