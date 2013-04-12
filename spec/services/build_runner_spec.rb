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
      it 'checks style guide and notifies github of the failed build' do
        guide = stub(check: nil, violations: ['violation'])
        diff = stub(additions: 'somecode')
        StyleGuide.stubs(new: guide)
        GitDiff.stubs(new: diff)
        runner = BuildRunner.new
        commit = stub
        patch = stub
        api = stub(
          create_pending_status: nil,
          create_successful_status: nil,
          create_failure_status: nil,
          patch: patch
        )

        runner.run(commit, api)

        expect(api).to have_received(:create_pending_status).
          with(commit, 'Hound is working...')
        expect(guide).to have_received(:check).with(diff.additions)
        expect(api).to have_received(:create_failure_status).
          with(commit, 'Hound does not approve')
      end
    end

    context 'without violations' do
      it 'checks style guide and notifies github of the passing build' do
        guide = stub(check: nil, violations: [])
        diff = stub(additions: 'somecode')
        StyleGuide.stubs(new: guide)
        GitDiff.stubs(new: diff)
        runner = BuildRunner.new
        commit = stub
        patch = stub
        api = stub(
          create_pending_status: nil,
          create_successful_status: nil,
          create_failure_status: nil,
          patch: patch
        )

        runner.run(commit, api)

        expect(api).to have_received(:create_pending_status).
          with(commit, 'Hound is working...')
        expect(guide).to have_received(:check).with(diff.additions)
        expect(api).to have_received(:create_successful_status).
          with(commit, 'Hound approves')
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
end
