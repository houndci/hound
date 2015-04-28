module Language
  class RubyLocalLinter < LocalLinter
    private

    def style_guide_name
      StyleGuide::Ruby
    end
  end
end
