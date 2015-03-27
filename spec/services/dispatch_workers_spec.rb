require "rails_helper"

describe DispatchWorkers do
  describe "#run" do
    context "for a Ruby file" do
      it "runs Language::RubyLegacyWorker" do
        file = double("File", filename: "foo.rb")
        pull_request = stub_pull_request(pull_request_files: [file])
        build = create(:build)
        repo_config = stub_repo_config
        worker = stub_worker(Language::RubyLegacyWorker)

        DispatchWorkers.run(pull_request, build)

        build_worker = build.build_workers.first
        expect(Language::RubyLegacyWorker).to have_received(:new).
          with(build_worker, file, repo_config, repository_owner_name)
        expect(worker).to have_received(:run)
      end

      context "when ruby is not enabled for the repo" do
        it "does not run the worker" do
          file = double("File", filename: "foo.rb")
          pull_request = stub_pull_request(pull_request_files: [file])
          build = create(:build)
          repo_config = stub_repo_config
          worker = stub_worker(Language::RubyLegacyWorker, enabled?: false)

          DispatchWorkers.run(pull_request, build)

          build_worker = build.build_workers.first
          expect(Language::RubyLegacyWorker).to have_received(:new).
            with(build_worker, file, repo_config, repository_owner_name)
          expect(worker).not_to have_received(:run)
        end
      end

      context "when have multiple files" do
        it "creates multiple build workers" do
          file = double("File", filename: "foo.rb")
          pull_request = stub_pull_request(pull_request_files: [file, file])
          build = create(:build)
          repo_config = stub_repo_config
          worker = stub_worker(Language::RubyLegacyWorker)

          DispatchWorkers.run(pull_request, build)

          first_build_worker = build.build_workers.first
          last_build_worker = build.build_workers.last
          expect(Language::RubyLegacyWorker).to have_received(:new).
            with(first_build_worker, file, repo_config, repository_owner_name)
          expect(Language::RubyLegacyWorker).to have_received(:new).
            with(last_build_worker, file, repo_config, repository_owner_name)
          expect(worker).to have_received(:run).twice
          expect(build.build_workers.count).to eq(2)
        end
      end
    end

    context "for a CoffeeScript file" do
      it "runs Language::CoffeeScriptLegacyWorker" do
        file = double("File", filename: "foo.coffee.js")
        pull_request = stub_pull_request(pull_request_files: [file])
        build = create(:build)
        repo_config = stub_repo_config
        worker = stub_worker(Language::CoffeeScriptLegacyWorker)

        DispatchWorkers.run(pull_request, build)

        build_worker = build.build_workers.first
        expect(Language::CoffeeScriptLegacyWorker).to have_received(:new).
          with(build_worker, file, repo_config, repository_owner_name)
        expect(worker).to have_received(:run)
      end

      context "when CoffeeScript is not enabled for the repo" do
        it "does not run the worker" do
          file = double("File", filename: "foo.coffee.js")
          pull_request = stub_pull_request(pull_request_files: [file])
          build = create(:build)
          repo_config = stub_repo_config
          worker = stub_worker(
            Language::CoffeeScriptLegacyWorker,
            enabled?: false
          )

          DispatchWorkers.run(pull_request, build)

          build_worker = build.build_workers.first
          expect(Language::CoffeeScriptLegacyWorker).to have_received(:new).
            with(build_worker, file, repo_config, repository_owner_name)
          expect(worker).not_to have_received(:run)
        end
      end

      context "when file is not included" do
        it "does not run the worker" do
          file = double("File", filename: "foo.coffee.js")
          pull_request = stub_pull_request(pull_request_files: [file])
          build = create(:build)
          repo_config = stub_repo_config
          worker = stub_worker(
            Language::CoffeeScriptLegacyWorker,
            file_included?: false
          )

          DispatchWorkers.run(pull_request, build)

          build_worker = build.build_workers.first
          expect(Language::CoffeeScriptLegacyWorker).to have_received(:new).
            with(build_worker, file, repo_config, repository_owner_name)
          expect(worker).not_to have_received(:run)
        end
      end
    end

    context "for a JavaScript file" do
      it "runs Language::CoffeeScriptLegacyWorker" do
        file = double("File", filename: "foo.js")
        pull_request = stub_pull_request(pull_request_files: [file])
        build = create(:build)
        repo_config = stub_repo_config
        worker = stub_worker(
          Language::JavaScriptLegacyWorker
        )

        DispatchWorkers.run(pull_request, build)

        build_worker = build.build_workers.first
        expect(Language::JavaScriptLegacyWorker).to have_received(:new).
          with(build_worker, file, repo_config, repository_owner_name)
        expect(worker).to have_received(:run)
      end

      context "when javascript is not enabled for the repo" do
        it "does not run the worker" do
          file = double("File", filename: "foo.js")
          pull_request = stub_pull_request(pull_request_files: [file])
          build = create(:build)
          repo_config = stub_repo_config
          worker = stub_worker(
            Language::JavaScriptLegacyWorker, enabled?: false
          )

          DispatchWorkers.run(pull_request, build)

          build_worker = build.build_workers.first
          expect(Language::JavaScriptLegacyWorker).to have_received(:new).
            with(build_worker, file, repo_config, repository_owner_name)
          expect(worker).not_to have_received(:run)
        end
      end

      context "when file is not included" do
        it "does not run the worker" do
          file = double("File", filename: "foo.js")
          pull_request = stub_pull_request(pull_request_files: [file])
          build = create(:build)
          repo_config = stub_repo_config
          worker = stub_worker(
            Language::JavaScriptLegacyWorker,
            file_included?: false
          )

          DispatchWorkers.run(pull_request, build)

          build_worker = build.build_workers.first
          expect(Language::JavaScriptLegacyWorker).to have_received(:new).
            with(build_worker, file, repo_config, repository_owner_name)
          expect(worker).not_to have_received(:run)
        end
      end
    end

    context "for a SCSS file" do
      context "when iron worker is disbaled" do
        it "runs Language::ScssLegacyWorker" do
          file = double("File", filename: "foo.scss")
          pull_request = stub_pull_request(pull_request_files: [file])
          build = create(:build)
          repo_config = stub_repo_config
          worker = stub_worker(Language::ScssLegacyWorker)

          DispatchWorkers.run(pull_request, build)

          build_worker = build.build_workers.first
          expect(Language::ScssLegacyWorker).to have_received(:new).
            with(build_worker, file, repo_config, repository_owner_name)
          expect(worker).to have_received(:run)
        end
      end

      context "when iron worker enabled" do
        it "runs Language::Scss" do
          enable_iron_worker
          file = double("File", filename: "foo.scss")
          pull_request = stub_pull_request(pull_request_files: [file])
          build = create(:build)
          repo_config = stub_repo_config
          worker = stub_worker(Language::Scss)

          DispatchWorkers.run(pull_request, build)

          build_worker = build.build_workers.first
          expect(Language::Scss).to have_received(:new).
            with(build_worker, file, repo_config, repository_owner_name)
          expect(worker).to have_received(:run)
        end
      end

      context "when SCSS is not enabled for the repo" do
        it "does not run the worker" do
          enable_iron_worker
          file = double("File", filename: "foo.scss")
          pull_request = stub_pull_request(pull_request_files: [file])
          build = create(:build)
          repo_config = stub_repo_config
          worker = stub_worker(Language::Scss, enabled?: false)

          DispatchWorkers.run(pull_request, build)

          build_worker = build.build_workers.first
          expect(Language::Scss).to have_received(:new).
            with(build_worker, file, repo_config, repository_owner_name)
          expect(worker).not_to have_received(:run)
        end
      end

      context "when file is not included" do
        it "does not run the worker" do
          enable_iron_worker
          file = double("File", filename: "foo.scss")
          pull_request = stub_pull_request(pull_request_files: [file])
          build = create(:build)
          repo_config = stub_repo_config
          worker = stub_worker(Language::Scss, file_included?: false)

          DispatchWorkers.run(pull_request, build)

          build_worker = build.build_workers.first
          expect(Language::Scss).to have_received(:new).
            with(build_worker, file, repo_config, repository_owner_name)
          expect(worker).not_to have_received(:run)
        end
      end
    end

    context "for an unsupported language" do
      it "runs the UnsupportedWorker and does nothing" do
        file = double("File", filename: "foo.unsupported")
        pull_request = stub_pull_request(pull_request_files: [file])
        build = create(:build)
        repo_config = stub_repo_config
        worker = stub_worker(Language::Unsupported)

        DispatchWorkers.run(pull_request, build)

        build_worker = build.build_workers.first
        expect(Language::Unsupported).to have_received(:new).
          with(build_worker, file, repo_config, repository_owner_name)
        expect(worker).to have_received(:run)
      end
    end
  end

  private

  def stub_pull_request(options = {})
    head_commit = double("Commit", file_content: "")
    defaults = {
      file_content: "",
      head_commit: head_commit,
      pull_request_files: [],
      repository_owner_name: repository_owner_name
    }

    double("PullRequest", defaults.merge(options))
  end

  def repository_owner_name
    "some_org"
  end

  def stub_repo_config(options = {})
    default_options = {
      enabled_for?: true,
      for: {},
      ignored_javascript_files: []
    }
    repo_config = double(
      "RepoConfig",
      default_options.merge(options)
    )
    allow(RepoConfig).to receive(:new).and_return(repo_config)

    repo_config
  end

  def stub_worker(name, options = {})
    default_options = {
      enabled?: true,
      file_included?: true,
      run: true,
      repo_config: stub_pull_request,
    }

    worker = double(
      name.to_s,
      default_options.merge(options)
    )
    allow(name).to receive(:new).and_return(worker)

    worker
  end

  def enable_iron_worker
    allow(ENV).
      to receive(:[]).with("IRON_WORKER_ENABLED").and_return(true)
  end
end
