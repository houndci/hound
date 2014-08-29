class Commit
  attr_reader :repo_name, :sha

  def initialize(repo_name, sha, github)
    @repo_name = repo_name
    @sha = sha
    @github = github
  end

  def files
    @files ||= github_files.map { |file| build_commit_file(file) }
  end

  def file_content(filename)
    contents = @github.file_contents(repo_name, filename, sha)
    if contents && contents.content
      Base64.decode64(contents.content)
    else
      ""
    end
  rescue Octokit::NotFound
    ""
  end

  private

  def build_commit_file(file)
    CommitFile.new(file, self)
  end

  def github_files
    @github.commit_files(repo_name, sha)
  end
end
