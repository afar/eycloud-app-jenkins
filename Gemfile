source "https://rubygems.org"

gem "rack"
gem "rake"
gem 'engineyard'
gem 'mysql2'

# this is a hack to compensate for a double bug
# by Riddle infering version, and EngineYard not providing version
ENV['SPHINX_VERSION'] = '2.0.9'
gem 'thinking-sphinx', :require => 'thinking_sphinx'
