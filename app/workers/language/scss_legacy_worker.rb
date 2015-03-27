module Language
  class ScssLegacyWorker < LegacyWorker
    private

    def style_guide_name
      StyleGuide::Scss
    end
  end
end
