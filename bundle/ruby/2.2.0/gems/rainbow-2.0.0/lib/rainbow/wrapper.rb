require 'rainbow/presenter'
require 'rainbow/null_presenter'

module Rainbow

  class Wrapper
    attr_accessor :enabled

    def initialize(enabled = true)
      @enabled = enabled
    end

    def wrap(string)
      if enabled
        Rainbow::Presenter.new(string.to_s)
      else
        Rainbow::NullPresenter.new(string.to_s)
      end
    end
  end

end
