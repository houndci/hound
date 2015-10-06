require 'monitor'

class MultiThreadedSimpleRandom < SimpleRandom
  class << self
    @instances = nil

    def instance

      unless @instances
        extend MonitorMixin

        self.synchronize do
          @instances ||= {}
        end
      end

      instance_id = Thread.current.object_id

      unless @instances[instance_id]
        self.synchronize do
          @instances[instance_id] ||= new
        end
      end

      @instances[instance_id]
    end
  end

  private_class_method :new
end