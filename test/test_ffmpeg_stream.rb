require 'ffmpeg/test_case'

class TestFFMPEGStream < FFMPEG::TestCase

  def setup
    super

    @fc = FFMPEG::FormatContext.new @thumbs_out, true
    @s = @fc.output_stream(FFMPEG::Codec::VIDEO, 'wmv', :bit_rate => 202_396,
                           :width => 196, :height => 144,
                           :fps => FFMPEG.Rational(25, 1))
  end

  def test_codec_context
    assert_equal 'msmpeg4', @s.codec_context.codec.name
  end

  def test_context_defaults
    @s.context_defaults FFMPEG::Codec::VIDEO

    assert_equal FFMPEG::PixelFormat::NONE, @s.codec_context.pixel_format
  end

  def test_r_frame_rate
    @s.r_frame_rate = FFMPEG.Rational(10, 1)

    assert_equal FFMPEG.Rational(10, 1), @s.r_frame_rate
  end

  def test_r_frame_rate_equals
    r = FFMPEG.Rational(10, 1)
    @s.r_frame_rate = r

    assert_equal r, @s.r_frame_rate
    refute_same  r, @s.r_frame_rate
  end

  def test_time_base
    @s.time_base = FFMPEG.Rational(10, 1)

    assert_equal FFMPEG.Rational(10, 1), @s.time_base
  end

  def test_time_base_equals
    r = FFMPEG.Rational(10, 1)
    @s.time_base = r

    assert_equal r, @s.time_base
    refute_same  r, @s.time_base
  end

  def test_type
    assert_equal :VIDEO, @s.type
  end

end

