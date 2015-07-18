module StyleGuide
  class Go < Base
    LANGUAGE = "go"

    def file_review(commit_file)
      Resque.enqueue(
        GoReviewJob,
        filename: commit_file.filename,
        commit_sha: commit_file.sha,
        pull_request_number: commit_file.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: repo_config.raw_for(LANGUAGE),
      )

      FileReview.new(filename: commit_file.filename)
    end

    def file_included?(commit_file)
      !vendored?(commit_file.filename)
    end

    private

    def vendored?(filename)
      path_components = Pathname(filename).each_filename

      path_components.include?("vendor") ||
        path_components.take(2) == ["Godeps", "_workspace"]
    end
  end
end
