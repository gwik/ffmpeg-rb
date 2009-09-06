require 'ffmpeg/test_case'

class TestFFMPEGFormatParameters < FFMPEG::TestCase

  def setup
    super

    @fp = FFMPEG::FormatParameters.new
  end

  def test_channel
    @fp.channel = 1
    assert_equal 1, @fp.channel
  end

  def test_channels
    @fp.channels = 2
    assert_equal 2, @fp.channels
  end

  def test_height
    @fp.height = 30
    assert_equal 30, @fp.height
  end

  def test_pixel_format
    @fp.channel = FFMPEG::PixelFormat::YUV420P
    assert_equal FFMPEG::PixelFormat::YUV420P, @fp.pixel_format
  end

  def test_sample_rate
    @fp.sample_rate = 16_000
    assert_equal 16_000, @fp.sample_rate
  end

  def test_width
    @fp.width = 40
    assert_equal 40, @fp.width
  end

  def test_standard
    @fp.standard = 'NTSC'
    assert_equal 'NTSC', @fp.standard
  end

end

