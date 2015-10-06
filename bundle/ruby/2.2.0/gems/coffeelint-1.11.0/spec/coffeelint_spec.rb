require 'spec_helper'

describe Coffeelint do
  it 'should error with semicolon' do
    results = Coffeelint.lint('apple;')
    expect(results.length).to eq 1
    result = results[0]
    expect(result['message']).to include 'trailing semicolon'
  end

  it 'should be able to disable a linter' do
    results = Coffeelint.lint('apple;', :no_trailing_semicolons =>  { :level => "ignore" } )
    expect(results.length).to eq 0
  end

  it 'should be able to take a config file in the parameters' do
    File.open('/tmp/coffeelint.json', 'w') {|f| f.write(JSON.dump({:no_trailing_semicolons => { :level => "ignore" }})) }
    results = Coffeelint.lint('apple;', :config_file => "/tmp/coffeelint.json")
    expect(results.length).to eq 0
  end

  it 'should report missing fat arrow' do
    results = Coffeelint.lint "hey: ->\n  @bort()\n", :missing_fat_arrows => { :level => "error" }
    expect(results.length).to eq 1
  end

  it 'should report unnecessary fat arrow' do
    results = Coffeelint.lint "hey: =>\n  bort()\n", :no_unnecessary_fat_arrows => { :level => "error" }
    expect(results.length).to eq 1
  end

  it 'should report cyclomatic complexity' do
    results = Coffeelint.lint(<<-EOF, :cyclomatic_complexity => { :level => "error" })
      x = ->
        1 and 2 and 3 and
        4 and 5 and 6 and
        7 and 8 and 9 and
        10 and 11
    EOF
    expect(results.length).to eq 1
    expect(results[0]['name']).to eq 'cyclomatic_complexity'
  end
end
