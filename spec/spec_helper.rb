require File.dirname(__FILE__) + '/../ffmpeg'
require 'rubygems'
require 'spec'

$test_file = ENV['TEST_FILE'] || File.dirname(__FILE__) + '/../in.mpeg'
