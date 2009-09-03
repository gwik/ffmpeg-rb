class FFMPEG::Rational

  include Comparable

  inline :C do |builder|
    FFMPEG.builder_defaults builder

    builder.map_c_const 'AV_ROUND_DOWN'     => ['int', :ROUND_DOWN]
    builder.map_c_const 'AV_ROUND_INF'      => ['int', :ROUND_INF]
    builder.map_c_const 'AV_ROUND_NEAR_INF' => ['int', :ROUND_NEAR_INF]
    builder.map_c_const 'AV_ROUND_UP'       => ['int', :ROUND_UP]
    builder.map_c_const 'AV_ROUND_ZERO'     => ['int', :ROUND_ZERO]

    builder.prefix <<-C
      static void free_rational(AVRational * rational) {
        av_free(rational);
      }
    C

    ##
    # :singleton-method: from

    builder.c_singleton <<-C
      VALUE from(double value, int max) {
        AVRational *ptr = av_mallocz(sizeof(AVRational));
        AVRational rational = av_d2q(value, max);

        ptr->num = rational.num;
        ptr->den = rational.den;

        return Data_Wrap_Struct(self, NULL, free_rational, ptr);
      }
    C

    ##
    # :singleton-method: rescale_rnd
    #
    # Rescale +a+ by +b+/+c+ using rounding method +rounding+

    builder.c_singleton <<-C
      int64_t rescale_rnd(int64_t a, int64_t b, int64_t c, int rounding) {
        return av_rescale_rnd(a, b, c, rounding);
      }
    C

    builder.c_singleton <<-C
      VALUE allocate() {
        AVRational *rational;

        rational = av_mallocz(sizeof(AVRational));

        if (!rational) {
          rb_raise(rb_eNoMemError, "could not allocate AVRational");
        }

        rational->num = 0;
        rational->den = 1;

        return Data_Wrap_Struct(self, 0, free_rational, rational);
      }
    C

    builder.struct_name = 'AVRational'
    builder.accessor :den, 'int'
    builder.accessor :num, 'int'
  end

  def initialize(num, den)
    self.num = num
    self.den = den
  end

  def self.rescale_q(a, bq, cq)
    b = bq.num * cq.den
    c = cq.num * bq.den

    rescale_rnd a, b, c, ROUND_NEAR_INF
  end

  def <=>(other)
    return nil unless self.class === other

    to_f <=> other.to_f
  end

  def inspect
    "#<%d/%d>" % [ num, den ]
  end

  def to_s
    "#{num}/#{den}"
  end

  def to_f
    num.to_f / den
  end

end

