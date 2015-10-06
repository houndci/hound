require 'spec_helper'

describe Capybara::Webkit, 'compatibility with selenium' do
  include AppRunner

  it 'generates the same events as selenium when filling out forms', selenium_compatibility: true do
    run_application_for_html(<<-HTML)
      <html><body>
        <form onsubmit="return false">
          <label for="one">One</label><input type="text" name="one" id="one" />
          <label for="two">Two</label><input type="text" name="two" id="two" />
          <label for="three">Three</label><input type="text" name="three" id="three" readonly="readonly" />
          <label for="textarea">Textarea</label>
          <textarea name="textarea" id="textarea"></textarea>
          <input type="submit" value="Submit" id="submit" />
        </form>
        <script type="text/javascript">
          window.log = [];
          var recordEvent = function (event) {
            log.push(event.target.id + '.' + event.type);
          };
          var elements = document.getElementsByTagName("input");
          var events = ["mousedown", "mouseup", "click", "keyup", "keydown",
                        "keypress", "focus", "blur", "input", "change"];
          for (var i = 0; i < elements.length; i++) {
            for (var j = 0; j < events.length; j++) {
              elements[i].addEventListener(events[j], recordEvent);
            }
          }
        </script>
      </body></html>
    HTML

    compare_events_for_drivers(:reusable_webkit, :selenium) do
      visit "/"
      fill_in "One", :with => "some value"
      fill_in "One", :with => "a new value"
      fill_in "Two", :with => "other value"
      fill_in "Three", :with => "readonly value"
      fill_in "Textarea", :with => "last value"
      click_button "Submit"
    end
  end

  def compare_events_for_drivers(first, second, &block)
    events_for_driver(first, &block).should == events_for_driver(second, &block)
  end

  def events_for_driver(name, &block)
    session = Capybara::Session.new(name, AppRunner.app)
    session.instance_eval(&block)
    session.evaluate_script("window.log")
  end
end
