class Commit
  pattr_initialize :repo_name, :sha, :github
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
end
