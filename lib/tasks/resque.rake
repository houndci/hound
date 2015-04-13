require "resque/tasks"
require "resque/scheduler/tasks"

task "resque:setup" => :environment
