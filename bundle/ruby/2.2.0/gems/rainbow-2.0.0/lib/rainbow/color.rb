module Rainbow
  class Color

    attr_reader :ground

    def self.build(ground, values)
      unless [1, 3].include?(values.size)
        fail ArgumentError,
          "Wrong number of arguments for color definition, should be 1 or 3"
      end

      color = values.size == 1 ? values.first : values

      case color
      when ::Fixnum
        Indexed.new(ground, color)
      when ::Symbol
        Named.new(ground, color)
      when ::Array
        RGB.new(ground, *color)
      when ::String
        RGB.new(ground, *parse_hex_color(color))
      end
    end

    def self.parse_hex_color(hex)
      hex = hex.gsub('#', '')
      r   = hex[0..1].to_i(16)
      g   = hex[2..3].to_i(16)
      b   = hex[4..5].to_i(16)

      [r, g, b]
    end

    class Indexed < Color

      attr_reader :num

      def initialize(ground, num)
        @ground = ground
        @num = num
      end

      def codes
        code = num + (ground == :foreground ? 30 : 40)

        [code]
      end

    end

    class Named < Indexed

      NAMES = {
        black:   0,
        red:     1,
        green:   2,
        yellow:  3,
        blue:    4,
        magenta: 5,
        cyan:    6,
        white:   7,
        default: 9,
      }

      def initialize(ground, name)
        unless color_names.include?(name)
          fail ArgumentError,
            "Unknown color name, valid names: #{color_names.join(', ')}"
        end

        super(ground, NAMES[name])
      end

      private

      def color_names
        NAMES.keys
      end

    end

    class RGB < Indexed

      attr_reader :r, :g, :b

      def self.to_ansi_domain(value)
        (6 * (value / 256.0)).to_i
      end

      def initialize(ground, *values)
        if values.min < 0 || values.max > 255
          fail ArgumentError, "RGB value outside 0-255 range"
        end

        super(ground, 8)
        @r, @g, @b = values
      end

      def codes
        super + [5, code_from_rgb]
      end

      private

      def code_from_rgb
        16 + self.class.to_ansi_domain(r) * 36 +
             self.class.to_ansi_domain(g) * 6  +
             self.class.to_ansi_domain(b)
      end

    end

  end
end
