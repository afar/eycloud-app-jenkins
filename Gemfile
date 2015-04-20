source "https://rubygems.org"

gem "rack"
gem "rake"
gem "chef"
gem 'engineyard', '~> 2.3'
gem "eycloud-helper-common"

gem 'moneta', '~> 0.6.0'

# this is a hack to compensate for a double bug
# by Riddle infering version, and EngineYard not providing version
ENV['SPHINX_VERSION'] = '2.0.9'
gem 'thinking-sphinx', '~> 3.0.6', :require => 'thinking_sphinx'
