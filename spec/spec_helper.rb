require File.dirname(__FILE__) + '/../ffmpeg'
require 'rubygems'
require 'spec'

if %w(on y yes yeah true 1).include?(ENV['DEBUG'].to_s.downcase)
  
  begin
    require 'ruby-debug'
    Debugger.start
    Debugger.settings[:autoeval] = true if Debugger.respond_to?(:settings)
    puts "=> Debugger enabled"
  rescue LoadError
    STDERR.puts "=> error : not able to load ruby debug"
  end
  
end
