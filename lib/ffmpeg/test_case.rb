require 'rubygems'
require 'fileutils'
require 'minitest/autorun'
require 'tmpdir'

require 'ffmpeg'

class FFMPEG::TestCase < MiniTest::Unit::TestCase

  def setup
    @thumbs_up = File.expand_path 'Thumbs Up!.3gp', 'test'

    @tmpdir = File.join Dir.tmpdir, "ffmpeg_test_#{$$}"

    FileUtils.mkdir_p @tmpdir

    @thumbs_out = File.join @tmpdir,
                            File.basename(@thumbs_up).sub(/3gp$/, 'wmv')
  end

  def teardown
    FileUtils.rm_rf @tmpdir
  end

  ##
  # From libavcodec/api-example.c

  def util_fill_frame(frame, index = 0)
    assert_equal FFMPEG::PixelFormat::YUV420P, frame.pixel_format,
                 'util_fill_frame only works with YUV420P frames'

    height   = frame.height
    width    = frame.width
    data     = frame.data
    linesize = frame.linesize

    # Y
    data_0 = data[0]
    line_0 = linesize[0]

    (0...height).each do |y|
      (0...width).each do |x|
        #p (y * line_0 + x) => (x + y + index * 3).chr
        data_0[y * line_0 + x, 1] = (x + y + index * 3).chr
      end
    end

    # Cb and Cr
    data_1 = data[1]
    line_1 = linesize[1]
    data_2 = data[2]
    line_2 = linesize[2]

    (0...(height / 2)).each do |y|
      (0...(width / 2)).each do |x|
        #p (y * line_1 + x) => (128 + y + index * 2).chr
        data_1[y * line_1 + x, 1] = (128 + y + index * 2).chr
        #p (y * line_2 + x) => ( 64 + x + index * 5).chr
        data_2[y * line_2 + x, 1] = ( 64 + x + index * 5).chr
      end
    end

    data
  end

end

