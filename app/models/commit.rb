class Commit
  pattr_initialize :repo_name, :sha, :github, [:pull_request_number]
  attr_reader :repo_name, :sha

  def file_content(filename)
    contents = @github.file_contents(repo_name, filename, sha)
    if contents && contents.content
      Base64.decode64(contents.content).force_encoding("UTF-8")
    else
      ""
    end
  rescue Octokit::NotFound
    ""
  end

  def add_comment(violation)
    github.add_comment(
      pull_request_number: pull_request_number,
      comment: violation.messages.join("<br>"),
      commit: self,
      filename: violation.filename,
      patch_position: violation.patch_position
    )
  end

  def comments
    @comments ||= if pull_request_number
      github.pull_request_comments(repo_name, pull_request_number)
    else
      github.commit_comments(repo_name, sha)
    end
  end

  def files
    @files ||= github_files.map { |file| build_commit_file(file) }
  end

  private

  def build_commit_file(file)
    CommitFile.new(file, self)
  end

  def github_files
    if pull_request_number
      github.pull_request_files(repo_name, pull_request_number)
    else
      github.commit_files(repo_name, sha)
    end
  end
end
