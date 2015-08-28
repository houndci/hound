class RubyViolations
  def initialize(repos)
    @repos = repos
  end

  def count
    message_counts.
      sort_by { |message_count| message_count[:count] }.
      reverse.
      take(20)
  end

  private

  def message_counts
    messages.
      group_by { |message| message }.
      map do |message, message_group|
        {
          message: message,
          count: message_group.count
        }
      end
  end

  def messages
    @messages ||= @repos.map do |repo|
      build_ids = repo.build_ids

      violations = Violation.
        where(build_id: build_ids).
        where("filename ILIKE ?", "%.rb")

      violations.pluck(:messages)
    end.flatten
  end
end
