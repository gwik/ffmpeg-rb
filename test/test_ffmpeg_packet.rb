require 'ffmpeg/test_case'

class TestFFMPEGPacket < FFMPEG::TestCase

  def setup
    super

    @p = FFMPEG::Packet.new
  end

  def test_buffer
    assert_kind_of FFMPEG::FrameBuffer, @p.buffer

    @p.buffer = 'foo'

    assert_equal 'foo', @p.buffer
  end

  def test_buffer_equals
    foo = 'foo'
    @p.buffer = foo

    assert_same foo, @p.buffer

    fb = FFMPEG::FrameBuffer.new 100
    @p.buffer = FFMPEG::FrameBuffer.new 100

    refute_same fb, @p.buffer
  end

  def test_clean
    @p.buffer = 'hi'

    @p.clean

    assert_equal  0, @p.size
    assert_equal -1, @p.pos

    assert_equal FFMPEG::NOPTS_VALUE, @p.pts
    assert_equal FFMPEG::NOPTS_VALUE, @p.dts

    assert_kind_of FFMPEG::FrameBuffer, @p.buffer
  end

end

