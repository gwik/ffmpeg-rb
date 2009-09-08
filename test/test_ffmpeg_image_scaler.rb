require 'ffmpeg/test_case'

class TestFFMPEGImageScaler < FFMPEG::TestCase

  def setup
    super

    @s = FFMPEG::ImageScaler.new 40, 30, FFMPEG::PixelFormat::YUV420P,
                                 80, 60, FFMPEG::PixelFormat::YUV420P,
                                 FFMPEG::ImageScaler::BICUBIC
  end

  def test_scale
    from = FFMPEG::Frame.new @s.from_height, @s.from_width, @s.from_pixel_format
    from.fill

    util_fill_frame from

    dest = @s.scale from

    assert_equal from.data_size * 4, dest.data_size
  end

end

