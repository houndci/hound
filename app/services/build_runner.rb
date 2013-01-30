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

  def run(pull_request, github_api)
    github_api.create_pending_status(pull_request, 'Hound is working...')
    guide.check(pull_request.additions)

    if guide.violations.any?
      github_api.create_failure_status(pull_request, 'Hound does not approve')
    else
      github_api.create_successful_status(pull_request, 'Hound approves')
    end
  end
end
