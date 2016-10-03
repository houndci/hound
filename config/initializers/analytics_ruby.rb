AnalyticsRuby = Segment::Analytics.new(
  write_key: ENV["SEGMENT_IO_WRITE_KEY"] || "",
  on_error: proc { |_status, message| puts message }
)
