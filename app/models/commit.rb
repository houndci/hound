class Commit
  pattr_initialize :repo_name, :sha, :github do
    @file_contents = {}
  end

  attr_reader :repo_name, :sha

  def file_content(filename)
    @file_contents[filename] ||= fetch_file(filename)
  end

  private

  def fetch_file(filename)
    contents = @github.file_contents(repo_name, filename, sha)

    if contents && contents.content
      Base64.decode64(contents.content).force_encoding("UTF-8")
    else
      ""
    end
  rescue Octokit::NotFound
    ""
  rescue Octokit::Forbidden => exception
    if exception.errors.any? && exception.errors.first[:code] == "too_large"
      ""
    else
      raise exception
    end
  end
end
