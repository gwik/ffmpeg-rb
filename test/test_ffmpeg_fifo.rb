require 'ffmpeg/test_case'

class TestFFMPEGFifo < FFMPEG::TestCase

  def setup
    super

    @fifo = FFMPEG::FIFO.new 20
    @buffer = "\0" * 5
  end

  def test_drain
    @fifo.write 'hello there'

    @fifo.drain 6

    @fifo.read @buffer, 5

    assert_equal 'there', @buffer
  end

  def test_inspect
    @fifo.write 'hello'

    assert_match %r%size 5 space 15%, @fifo.inspect
  end

  def test_read
    @fifo.write 'hello'

    @fifo.read @buffer, 5

    assert_equal 'hello', @buffer
  end

  def test_realloc
    @fifo.write 'hello there'

    @fifo.realloc 30

    assert_equal 11, @fifo.size
    assert_equal 19, @fifo.space
  end

  def test_reset
    @fifo.write 'hello there'

    @fifo.reset

    @fifo.write ' eric'

    @fifo.read @buffer, 5

    assert_equal ' eric', @buffer
  end

  def test_size
    @fifo.write 'hello there'

    assert_equal 11, @fifo.size
  end

  def test_space
    @fifo.write 'hello there'

    assert_equal 9, @fifo.space
  end

  def test_write
    @fifo.write 'hello'

    assert_equal 5, @fifo.size
  end

end

