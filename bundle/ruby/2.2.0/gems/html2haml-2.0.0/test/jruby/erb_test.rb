#reopen classes that need to be modified for JRuby specific behavior
class ErbTest
  def test_two_multiline_erb_loud_scripts
    assert_equal(<<HAML.rstrip, render_erb(<<ERB))
.blah
  = foo +          |
    bar.baz.bang + |
    baz            |
  = foo.bar do |
      bang     |
    end        |
  %p foo
HAML
<div class="blah">
  <%=
    foo +
    bar.baz.bang +
    baz
  %>
  <%= foo.bar do
        bang
      end %>
  <p>foo</p>
</div>
ERB
  end

end
