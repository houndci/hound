module StyleGuide
  class Scss < Base
    LANGUAGE = "scss"

    def file_review(commit_file)
      Resque.enqueue(
        ScssReviewJob,
        filename: commit_file.filename,
        commit_sha: commit_file.sha,
        pull_request_number: commit_file.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: repo_config.raw_for(LANGUAGE)
      )

      FileReview.new(filename: commit_file.filename)
    end

    def file_included?(_)
      true
    end
  end
end
