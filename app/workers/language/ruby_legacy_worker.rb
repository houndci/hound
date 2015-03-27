module Language
  class RubyLegacyWorker < LegacyWorker
    private

    def style_guide_name
      StyleGuide::Ruby
    end
  end
end
