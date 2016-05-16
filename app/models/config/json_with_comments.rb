module Config
  class JsonWithComments
    SINGLE_LINE_COMMENT = 1
    MULTI_LINE_COMMENT = 2

    attr_private_initialize :content

    def without_comments
      inside_comment = false
      inside_string = false
      result = ""
      offset = 0

      content.each_char.with_index do |current_char, index|
        next_char = content[index + 1]
        fragment = "#{current_char}#{next_char}"

        if !inside_comment && current_char == '"'
          escaped = content[index - 1] == '\\' && content[index - 2] != '\\'

          unless escaped
            inside_string = !inside_string
          end
        end

        unless inside_string
          if !inside_comment
            if fragment == "//"
              result << content[offset...index].gsub(/\s*$/, "")
              offset = index
              inside_comment = SINGLE_LINE_COMMENT
            elsif fragment == "/*"
              result << content[offset...index]
              offset = index
              inside_comment = MULTI_LINE_COMMENT
            end
          elsif inside_comment == SINGLE_LINE_COMMENT
            if current_char == "\n"
              inside_comment = false
              offset = index
            end
          elsif inside_comment == MULTI_LINE_COMMENT && fragment == "*/"
            inside_comment = false
            offset = index + 3
          end
        end
      end

      if inside_comment
        result
      else
        "#{result}#{content[offset..-1]}"
      end
    end
  end
end
