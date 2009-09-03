require 'ffmpeg/test_case'

class TestFFMPEGCodecContext < FFMPEG::TestCase

  def setup
    super

    @format_context = FFMPEG::FormatContext.new @thumbs_up
    @codec_context = @format_context.video_stream.codec_context
  end

  def test_bit_rate
    assert_equal 0, @codec_context.bit_rate
  end

  def test_codec
    assert_equal nil, @codec_context.codec

    @codec_context.open @codec_context.decoder

    assert_equal 'h264', @codec_context.codec.name
  end

  def test_codec_id
    assert_equal 28, @codec_context.codec_id
  end

  def test_codec_name
    assert_equal '', @codec_context.codec_name
  end

  def test_codec_type
    assert_equal :VIDEO, @codec_context.codec_type
  end

  def test_decoder
    decoder = @codec_context.decoder
    assert_equal 'h264', decoder.name
  end

  def test_dimensions
    assert_equal '144x176', @codec_context.dimensions
  end

  def test_gop_size
    assert_equal 12, @codec_context.gop_size
  end

  def test_height
    assert_equal 144, @codec_context.height
  end

  def test_pixel_format
    assert_equal FFMPEG::PixelFormat::YUV420P, @codec_context.pixel_format
  end

  def test_sample_fmt
    assert_equal 1, @codec_context.sample_fmt
  end

  def test_time_base
    assert_equal FFMPEG::Rational.new(1, 5994), @codec_context.time_base
  end

  def test_width
    assert_equal 176, @codec_context.width
  end

end

