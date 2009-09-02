require 'ffmpeg_test_case'

class TestFFMPEGCodec < FFMPEG::TestCase

  def setup
    @codec = FFMPEG::Codec.for_encoder 'mpeg1video'
  end

  def test_class_for_decoder_id
    decoder = FFMPEG::Codec.for_decoder 1
    
    assert_kind_of FFMPEG::Codec, decoder
    assert_equal 'mpeg1video', decoder.name
    assert_equal :VIDEO, decoder.type
  end

  def test_class_for_decoder_name
    decoder = FFMPEG::Codec.for_decoder 'mpeg1video'

    assert_kind_of FFMPEG::Codec, decoder
    assert_equal 'mpeg1video', decoder.name
    assert_equal :VIDEO, decoder.type
  end

  def test_class_for_encoder_id
    encoder = FFMPEG::Codec.for_encoder 1

    assert_kind_of FFMPEG::Codec, encoder
    assert_equal 'mpeg1video', encoder.name
    assert_equal :VIDEO, encoder.type
  end

  def test_class_for_encoder_name
    encoder = FFMPEG::Codec.for_encoder 'mpeg1video'

    assert_kind_of FFMPEG::Codec, encoder
    assert_equal 'mpeg1video', encoder.name
    assert_equal :VIDEO, encoder.type
  end

  def test_inspect
    assert_equal '#<FFMPEG::Codec VIDEO:mpeg1video>', @codec.inspect
  end

  def test_capabilities
    assert_equal FFMPEG::Codec::DELAY, @codec.capabilities
  end

  def test_long_name
    assert_equal 'MPEG-1 video', @codec.long_name
  end

  def test_name
    assert_equal 'mpeg1video', @codec.name
  end

  def test_next
    refute_nil @codec.next
  end

  def test_pixel_formats
    assert_equal [0], @codec.pixel_formats
  end

  def test_supported_framerates
    expected = [
      FFMPEG::Rational.new(5,     1),
      FFMPEG::Rational.new(10,    1),
      FFMPEG::Rational.new(12,    1),
      FFMPEG::Rational.new(15,    1),
      FFMPEG::Rational.new(15,    1), # WTF?
      FFMPEG::Rational.new(24000, 1001),
      FFMPEG::Rational.new(24,    1),
      FFMPEG::Rational.new(25,    1),
      FFMPEG::Rational.new(30000, 1001),
      FFMPEG::Rational.new(30,    1),
      FFMPEG::Rational.new(50,    1),
      FFMPEG::Rational.new(60000, 1001),
      FFMPEG::Rational.new(60,    1),
    ]

    assert_equal expected, @codec.supported_framerates.sort
  end

  def test_type
    assert_equal :VIDEO, @codec.type
  end

end

