class ModifiedFile
  def initialize(pull_request_file, pull_request, api)
    @pull_request_file = pull_request_file
    @pull_request = pull_request
    @api = api
  end

  def filename
    @pull_request_file.filename
  end

  def status
    @pull_request_file.status
  end

  def contents
    contents = @api.file_contents(
      @pull_request.full_repo_name,
      @pull_request_file.filename,
      @pull_request.head_sha
    )
    Base64.decode64(contents.content)
  end

  def line_numbers
    @line_numbers ||= DiffPatch.new(patch).modified_line_numbers
  end

  private

  def patch
    @pull_request_file.patch
  end
end
