require 'rubygems'
require 'minitest/autorun'
require 'ffmpeg'

class FFMPEG::TestCase < MiniTest::Unit::TestCase

  def setup
    @thumbs_up = File.expand_path 'Thumbs Up!.3gp', 'test'
  end

end

