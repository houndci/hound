require 'spec_helper'

describe BuildRunner do
  it 'initializes style guide with all rules' do
    StyleGuide.stubs(:new)
    rules = stubbed_rules

    BuildRunner.new

    expect(StyleGuide).to have_received(:new).with(rules)
  end

  describe '#run' do
    context 'with violations' do
      it 'sets the GitHub status to pending' do
        guide = stub(check: nil, violations: ['violation'])
        StyleGuide.stubs(new: guide)
        runner = BuildRunner.new

        runner.run(pull_request, api)

        expect(api).to have_received(:create_pending_status).
          with(pull_request, 'Hound is working...')
      end

      it 'sets the GitHub status to failure' do
        guide = stub(check: nil, violations: ['violation'])
        StyleGuide.stubs(new: guide)
        runner = BuildRunner.new

        runner.run(pull_request, api)

        expect(api).to have_received(:create_failure_status).
          with(pull_request, 'Hound does not approve')
      end

      it 'checks style guide' do
        guide = stub(check: nil, violations: ['violation'])
        StyleGuide.stubs(new: guide)
        runner = BuildRunner.new

        runner.run(pull_request, api)

        expect(guide).to have_received(:check).with(['addition'])
      end
    end

    context 'without violations' do
      it 'sets the GitHub status to pending' do
        guide = stub(check: nil, violations: [])
        StyleGuide.stubs(new: guide)
        runner = BuildRunner.new

        runner.run(pull_request, api)

        expect(api).to have_received(:create_pending_status).
          with(pull_request, 'Hound is working...')
      end

      it 'sets the GitHub status to success' do
        guide = stub(check: nil, violations: [])
        StyleGuide.stubs(new: guide)
        runner = BuildRunner.new

        runner.run(pull_request, api)

        expect(api).to have_received(:create_successful_status).
          with(pull_request, 'Hound approves')
      end

      it 'checks style guide' do
        guide = stub(check: nil, violations: [])
        StyleGuide.stubs(new: guide)
        runner = BuildRunner.new

        runner.run(pull_request, api)

        expect(guide).to have_received(:check).with(['addition'])
      end
    end
  end

  def stubbed_rules
    rules = [
      BraceRule,
      BracketRule,
      MethodParenRule,
      ParenRule,
      QuoteRule,
      WhitespaceRule
    ]

    stuff = rules.map do |rule|
      rule_stub = stub
      rule.stubs(new: rule_stub)
      rule_stub
    end
  end

  def api
    @api ||= stub(
      create_pending_status: nil,
      create_successful_status: nil,
      create_failure_status: nil
    )
  end

  def pull_request
    @pull_request ||= stub(additions: ['addition'])
  end
end
