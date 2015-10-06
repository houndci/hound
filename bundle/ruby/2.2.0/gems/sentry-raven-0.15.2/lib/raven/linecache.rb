# A much simpler source line cacher because linecache sucks at platform compat

module Raven
  class LineCache
    class << self
      CACHE = {}

      def is_valid_file(path)
        lines = getlines(path)
        return lines != nil
      end

      def getlines(path)
        CACHE[path] ||= begin
          IO.readlines(path)
        rescue
          nil
        end
      end

      def getline(path, n)
        return nil if n < 1
        lines = getlines(path)
        return nil if lines == nil
        lines[n - 1]
      end
    end
  end
end
