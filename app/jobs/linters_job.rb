class LintersJob < ApplicationJob
  sidekiq_options queue: :linters
end
