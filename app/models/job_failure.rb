class JobFailure < OpenStruct
  extend ActiveModel::Naming

  def id
    self["jid"]
  end

  def job_class
    self["wrapped"]
  end

  def failed_at
    self["failed_at"]
  end

  def error_message
    self["error_message"]
  end

  def self.grouped
    Sidekiq::DeadSet.new.
      map { |failure| JobFailure.new(failure.item) }.
      group_by do |job|
        if job.error_message.match?(%r{/statuses/\w+: 404 - Not Found})
          job.error_message[/.+?\/statuses\//]
        else
          job.error_message
        end
      end
  end

  def self.remove(ids)
    dead_set = Sidekiq::DeadSet.new
    ids.each do |id|
      dead_set.find_job(id).delete
    end
  end
end
