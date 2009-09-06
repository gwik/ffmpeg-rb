require 'ffmpeg/test_case'

class TestFFMPEGFrame < FFMPEG::TestCase

  def setup
    super

    @frame = FFMPEG::Frame.new 40, 30, FFMPEG::PixelFormat::YUV420P
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

  def test_data
    @frame.fill

    data = @frame.data

    assert_equal 4,  data.length
    assert_equal 40, data[0].length
    assert_equal 20, data[1].length
    assert_equal 20, data[2].length
    assert_equal 0,  data[3].length
  end

  def test_defaults
    @frame.defaults

    # this test sucks, the underlying C call does these things now
    assert_equal FFMPEG::NOPTS_VALUE, @frame.pts
    assert_equal true, @frame.key_frame
  end

  def test_fill
    assert_equal [ 0,  0,  0, 0], @frame.data.map { |d| d.length }

    @frame.fill

    assert_equal [40, 20, 20, 0], @frame.data.map { |d| d.length }
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

