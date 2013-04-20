require 'spec_helper'

describe BuildRunner do
  it 'initializes style guide' do
    StyleGuide.stubs(:new)

    BuildRunner.new

    expect(StyleGuide).to have_received(:new)
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
        api = stub(
          create_pending_status: nil,
          create_successful_status: nil,
          create_failure_status: nil,
          patch: stub
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
        api = stub(
          create_pending_status: nil,
          create_successful_status: nil,
          create_failure_status: nil,
          patch: stub
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
end
