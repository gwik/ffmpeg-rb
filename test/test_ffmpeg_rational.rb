require 'ffmpeg_test_case'

class TestFFMPEGRational < FFMPEG::TestCase

  def setup
    super

    @R = FFMPEG::Rational
    @rational = @R.new 25, 1
  end

  def test_class_from
    from = @R.from(25.0, 25)
    assert_equal 25, from.num
    assert_equal 1,  from.den
  end

  def test_class_rescale_q
    rescaled = @R.rescale_q(5, @R.new(6, 1), @R.new(7, 1))
    assert_equal 4, rescaled
  end

  def test_class_rescale_rnd
    rescaled = @R.rescale_rnd(5, 6, 7, @R::ROUND_ZERO)
    assert_equal 4, rescaled

    rescaled = @R.rescale_rnd(4, 2, 1, @R::ROUND_ZERO)
    assert_equal 8, rescaled
  end

  def test_inspect
    assert_equal '#<25/1>', @rational.inspect
  end

  def test_spaceship
    assert_equal -1, @rational.<=>(@R.new(26, 1))
    assert_equal  0, @rational.<=>(@rational)
    assert_equal  1, @rational.<=>(@R.new(24, 1))
  end

  def test_to_f
    assert_in_delta 25.0, @rational.to_f
  end

  def test_to_s
    assert_equal '25/1', @rational.to_s
  end

end

