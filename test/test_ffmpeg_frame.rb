require 'ffmpeg/test_case'

class TestFFMPEGFrame < FFMPEG::TestCase

  def setup
    super

    @frame = FFMPEG::Frame.new 40, 30, FFMPEG::PixelFormat::RGBA
    @frame.defaults
  end

  def test_class_from
    format_context = FFMPEG::FormatContext.new @thumbs_up
    codec_context = format_context.video_stream.codec_context
    frame = FFMPEG::Frame.from codec_context

    assert_equal 176, frame.width
    assert_equal 144, frame.height
    assert_equal FFMPEG::PixelFormat::YUV420P, frame.pixel_format
  end

  def test_defaults
    @frame.defaults

    # this test sucks, the underlying C call does these things now
    assert_equal FFMPEG::NOPTS_VALUE, @frame.pts
    assert_equal true, @frame.key_frame
  end

  def test_fill
    # this test sucks
    @frame.fill
  end

  def test_key_frame
    assert_equal true, @frame.key_frame
  end

  def test_key_frame_eh
    assert @frame.key_frame?
  end

  def test_picture_type
    @frame.picture_type = FFMPEG::PixelFormat::RGBA
    assert_equal FFMPEG::PixelFormat::RGBA, @frame.picture_type
  end

  def test_pts
    @frame.pts = 2
    assert_equal 2, @frame.pts
  end

  def test_quality
    @frame.quality = 2
    assert_equal 2, @frame.quality
  end

  def test_type
    assert_equal nil, @frame.type

    @frame.picture_type = FFMPEG::Frame::I_TYPE

    assert_equal :I_TYPE, @frame.type
  end

end

