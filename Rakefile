require 'rubygems'
require 'bundler'
require 'thinking_sphinx'

Rake::Task.define_task(:environment)

begin
  require 'thinking_sphinx/tasks'
rescue LoadError
  puts "You can't load Thinking Sphinx tasks unless the thinking-sphinx gem is installed."
end