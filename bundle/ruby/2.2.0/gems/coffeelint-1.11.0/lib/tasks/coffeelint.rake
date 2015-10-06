desc "lint application javascript"
task :coffeelint do
  failures = Coffeelint.run_test_suite('app') + Coffeelint.run_test_suite('spec')
  fail "Lint!" unless failures == 0
end
