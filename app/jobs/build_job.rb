class BuildJob < Struct.new(:build_runner)
  def perform
    build_runner.run
  end
end
