module StyleGuide
  class Scss < Base
    LANGUAGE = "scss"

    def file_review(file)
      Resque.enqueue(
        ScssReviewJob,
        filename: file.filename,
        commit_sha: file.sha,
        patch: file.patch_body,
        content: file.content,
        config: repo_config.raw_for(LANGUAGE)
      )

      FileReview.new(filename: file.filename)
    end

    def file_included?(_)
      true
    end
  end
end
