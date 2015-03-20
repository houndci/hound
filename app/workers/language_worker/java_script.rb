module LanguageWorker
  class JavaScript < LegacyWorker
    private

    def style_guide_name
      StyleGuide::JavaScript
    end
  end
end
