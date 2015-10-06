class Html2HamlTest

  def test_doctype
    empty_body = "\n%html\n  %head\n  %body"
    assert_equal '!!!' + empty_body, render("<!DOCTYPE html>")
    assert_equal '!!! 1.1' + empty_body, render('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">')
    assert_equal '!!! Strict' + empty_body, render('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">')
    assert_equal '!!! Frameset' + empty_body, render('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">')
    assert_equal '!!! Mobile 1.2' + empty_body, render('<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">')
    assert_equal '!!! Basic 1.1' + empty_body, render('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">')
    assert_equal '!!!' + empty_body, render('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">')
    assert_equal '!!! Strict' + empty_body, render('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">')
    assert_equal '!!! Frameset' + empty_body, render('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">')
    assert_equal '!!!' + empty_body, render('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">')
  end

  def test_xhtml_strict_doctype
    assert_equal(<<HAML.rstrip, render(<<HTML))
!!! Strict
%html
  %head
  %body
HAML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
HTML
  end

  def test_html_document_without_doctype
    assert_equal(<<HAML.rstrip, render(<<HTML))
%html
  %head
    %title Hello
  %body
    %p Hello
HAML
<html>
<head>
  <title>Hello</title>
</head>
<body>
  <p>Hello</p>
</body>
</html>
HTML
  end

  def test_should_have_attributes_without_values
    assert_equal('%input{:disabled => ""}/', render('<input disabled>'))
  end

  def test_style_to_css_filter_with_following_content
    assert_equal(<<HAML.rstrip, render(<<HTML))
%head
  :css
    foo {
        bar: baz;
    }
%body
  Hello
HAML
<head>
  <style type="text/css">
      foo {
          bar: baz;
      }
  </style>
</head>
<body>Hello</body>
HTML
  end
end
