module LanguageWorker
  class Ruby < LegacyWorker
    private

    def style_guide_name
      StyleGuide::Ruby
    end
  end
end
