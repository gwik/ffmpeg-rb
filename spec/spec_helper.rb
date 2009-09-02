require 'rubygems'
require 'spec'
require 'ffmpeg'

$test_file = ENV['TEST_FILE'] || File.join('spec', 'Thumbs Up!.3gp')
