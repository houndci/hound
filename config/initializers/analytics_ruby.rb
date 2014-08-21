AnalyticsRuby = Segment::Analytics.new(
  write_key: ENV["SEGMENT_IO_WRITE_KEY"] || "",
  on_error: Proc.new { |status, message| puts message }
)
