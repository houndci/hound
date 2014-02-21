class BuildJob < Struct.new(:build_runner)
  include Monitorable

  def perform
    build_runner.run
  end
end
