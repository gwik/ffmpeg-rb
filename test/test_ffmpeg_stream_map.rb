require 'ffmpeg/test_case'

class TestFFMPEGStreamMap < FFMPEG::TestCase

  def setup
    super

    @input_fc = FFMPEG::FormatContext.new @thumbs_up
    @output_fc = FFMPEG::FormatContext.new @thumbs_out, true

    @video = @output_fc.output_stream(FFMPEG::Codec::VIDEO, 'wmv',
                                      :bit_rate => 202_396,
                                      :width => 196, :height => 144,
                                      :fps => FFMPEG.Rational(25, 1))

    @audio = @output_fc.output_stream(FFMPEG::Codec::AUDIO, nil,
                                      :bit_rate => 64_000,
                                      :sample_rate => 16_000,
                                      :channels => 1)

    @sm = FFMPEG::StreamMap.new @input_fc
  end

  def test_add
    @sm.add @input_fc.video_stream, @video
    @sm.add @input_fc.audio_stream, @audio

    expected = {
      0 => [@video],
      1 => [@audio],
    }

    assert_equal expected, @sm.map
  end

  def test_add_mismatch
    e = assert_raises ArgumentError do
      @sm.add @input_fc.video_stream, @audio
    end

    assert_equal 'input and output stream types differ', e.message
  end

  def test_add_not_output
    e = assert_raises ArgumentError do
      @sm.add @input_fc.video_stream, @input_fc.video_stream
    end

    assert_equal 'output stream must belong to an output format context',
                 e.message
  end

  def test_add_wrong_input_file
    thumb = FFMPEG::FormatContext.new @thumbs_up

    e = assert_raises ArgumentError do
      @sm.add thumb.video_stream, @video
    end

    assert_equal 'input stream must belong to input format context', e.message
  end

  def test_empty_eh
    assert @sm.empty?

    @sm.add @input_fc.video_stream, @video

    refute @sm.empty?
  end

end

