module CommitHelper
  def stub_commit(files)
    stubbed_commit = instance_double("Commit")
    files.each do |name, content|
      allow(stubbed_commit).
        to receive(:file_content).
        with(name).
        and_return(content)
    end
    stubbed_commit
  end
end
