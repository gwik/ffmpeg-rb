require 'ffmpeg/test_case'

class TestFFMPEGOutputFormat < FFMPEG::TestCase

  def setup
    super

    @OF = FFMPEG::OutputFormat
    @of = @OF.guess_format nil, @thumbs_up, nil
  end

  def test_class_guess_format
    of = @OF.guess_format 'm4v', nil, nil
    assert_equal 'm4v', of.name

    of = @OF.guess_format nil, @thumbs_up, nil
    assert_equal '3gp', of.name

    of = @OF.guess_format nil, nil, 'video/mpeg'
    assert_equal 'mpeg', of.name
  end

  def test_class_guess_codec
    id = @of.guess_codec 'm4v', nil, nil, FFMPEG::Codec::VIDEO
    assert_equal FFMPEG::Codec::ID::H263, id

    id = @of.guess_codec nil, @thumbs_up, nil, FFMPEG::Codec::VIDEO
    assert_equal FFMPEG::Codec::ID::H263, id

    id = @of.guess_codec nil, nil, 'video/mpeg', FFMPEG::Codec::VIDEO
    assert_equal FFMPEG::Codec::ID::H263, id
  end

  def test_extensions
    assert_equal '3gp', @of.extensions
  end

  def test_flags
    assert_equal 64, @of.flags
  end

  def test_long_name
    assert_equal '3GP format', @of.long_name
  end

  def test_mime_type
    assert_raises ArgumentError do
      @of.mime_type
    end
  end

  def test_name
    assert_equal '3gp', @of.name
  end

end

