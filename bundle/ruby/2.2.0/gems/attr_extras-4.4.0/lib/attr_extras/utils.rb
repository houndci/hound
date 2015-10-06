module AttrExtras::Utils
  def self.flat_names(names)
    names.flatten.map { |x| x.to_s.sub(/!\z/, "") }
  end
end
