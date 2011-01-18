Accounting_101::Application.configure do
  config.generators do |g|
    g.integration_tool :rspec
    g.test_framework   :rspec
  end
end if defined? Accounting_101::Application
