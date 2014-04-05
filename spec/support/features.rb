module Features
  def screenshot
    if example.metadata[:js]
      name = Time.now.strftime('%Y-%m-%d-%H-%M-%S-%L')
      path = Rails.root.join(Capybara.save_and_open_page_path, "#{name}.png")
      save_screenshot(path)
      Launchy.open(path.to_s)
    else
      message = 'screenshot can only be used in JavaScript feature specs'
      raise ArgumentError.new(message)
    end
  end
end
