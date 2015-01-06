class Commit
  pattr_initialize :repo_name, :sha, :github
  attr_reader :repo_name, :sha
  attr_accessor :message

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

  def comments
    @github.commit_comments(repo_name, sha)
  end

  def add_comment(comment)
    @github.add_commit_comment(commit: self, comment: comment)
  end

  def subject
    message.to_s.split("\n\n").first || ""
  end

  def body
    message.to_s.split("\n\n", 2).last || ""
  end
end
