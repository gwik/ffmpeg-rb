require 'ffmpeg/test_case'

class TestFFMPEGFormatContext < FFMPEG::TestCase

  def setup
    super

    @FC = FFMPEG::FormatContext
    @fc = @FC.new @thumbs_up
  end

  def test_bit_rate
    assert_equal 63765, @fc.bit_rate
  end

  def test_duration
    assert_equal 2_624_000, @fc.duration
  end

  def test_file_size
    assert_equal 20915, @fc.file_size
  end

  def test_input_format
    assert_equal 'mov,mp4,m4a,3gp,3g2,mj2', @fc.input_format.name
  end

  def test_loop_output
    assert_equal 0, @fc.loop_output
  end

  def test_max_delay
    assert_equal 0, @fc.max_delay
  end

  def test_preload
    assert_equal 0, @fc.preload
  end

  def test_start_time
    assert_equal 0, @fc.start_time
  end

  def test_stream_info
    assert @fc.stream_info
  end

  def test_streams
    assert_equal 2, @fc.streams.length
  end

  def test_timestamp
    assert_equal 0, @fc.timestamp
  end

  def test_video_eh
    assert @fc.video?
  end

  def test_video_stream
    assert @fc.video_stream
  end

end

