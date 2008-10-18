module FFMPEG
  class Rational
    inline :C do |builder|
      FFMPEG.builder_defaults builder

      builder.map_c_const 'AV_ROUND_NEAR_INF' => ['int', :ROUND_NEAR_INF]

      ##
      # :singleton-method: from

      builder.c_singleton <<-C
        VALUE from(double value, int max) {
          AVRational rational;
          VALUE obj;

          rational = av_d2q(value, max);

          obj = Data_Wrap_Struct(self, 0, NULL, &rational);

          return obj;
        }
      C

      ##
      # :singleton-method: new

      builder.c_singleton <<-C
        VALUE new(VALUE num, VALUE den) {
          VALUE obj = Data_Wrap_Struct(self, 0, NULL, NULL);

          if (NIL_P(rb_funcall(obj, rb_intern("initialize"), 2, num, den)))
            return Qfalse;

          return obj;
        }
      C

      ##
      # :singleton-method: rescale_rnd

      builder.c_singleton <<-C
        int64_t rescale_rnd(int64_t a, int64_t b, int64_t c, int rounding) {
          return av_rescale_rnd(a, b, c, rounding);
        }
      C

      ##
      # :method: initialize

      builder.c <<-C
        VALUE initialize(int num, int den) {
          AVRational *rational;

          rational = av_mallocz(sizeof(AVRational));

          if (!rational) {
            rb_raise(rb_eNoMemError, "could not allocate AVRational");
          }

          rational->num = num;
          rational->den = den;

          DATA_PTR(self) = rational;

          return self;
        }
      C

      builder.struct_name = 'AVRational'
      builder.accessor :den, 'int'
      builder.accessor :num, 'int'
    end

    def self.rescale_q(a, bq, cq)
      b = bq.num * cq.den
      c = cq.num * bq.den

      rescale_rnd a, b, c, ROUND_NEAR_INF
    end

    def inspect
      "#<%s:%x %d/%d>" % [
        self.class, object_id,
        num, den
      ]
    end

    def to_f
      num.to_f / den
    end

  end
end