class FFMPEG::Codec

  inline :C do |builder|
    FFMPEG.builder_defaults builder

    builder.map_c_const :AVCODEC_MAX_AUDIO_FRAME_SIZE =>
                          ['int', :MAX_AUDIO_FRAME_SIZE]

    TYPE_CONSTS = [
      [:UNKNOWN,    :CODEC_TYPE_UNKNOWN,    :int],
      [:VIDEO,      :CODEC_TYPE_VIDEO,      :int],
      [:AUDIO,      :CODEC_TYPE_AUDIO,      :int],
      [:DATA,       :CODEC_TYPE_DATA,       :int],
      [:SUBTITLE,   :CODEC_TYPE_SUBTITLE,   :int],
      [:ATTACHMENT, :CODEC_TYPE_ATTACHMENT, :int],
      [:NB,         :CODEC_TYPE_NB,         :int],
    ]

    TYPE_CONSTS.each do |name, c_name, c_type|
      builder.map_c_const c_name => [c_type, name]
    end

    def self.type_name(type)
      TYPE_CONSTS.find do |name, c_name, c_type|
        type == self.const_get(name)
      end.first
    end

    ##
    # :singleton-method: for_decoder

    builder.c_singleton <<-C
      VALUE for_decoder(VALUE codec_id_or_name) {
        AVCodec *codec;
        char *name;
        VALUE obj;

        switch (TYPE(codec_id_or_name)) {
          case T_FIXNUM:
          case T_BIGNUM:
            codec = avcodec_find_decoder(NUM2INT(codec_id_or_name));
            break;
          default:
            codec_id_or_name = rb_str_to_str(codec_id_or_name);
            name = StringValueCStr(codec_id_or_name);
            codec = avcodec_find_decoder_by_name(name);
        }

        if (codec == NULL) return Qnil;

        obj = Data_Wrap_Struct(self, 0, 0, codec);

        rb_funcall(obj, rb_intern("initialize"), 0);

        return obj;
      }
    C

    ##
    # :singleton-method: for_encoder

    builder.c_singleton <<-C
      VALUE for_encoder(VALUE codec_id_or_name) {
        AVCodec *codec;
        char *name;
        VALUE obj;

        switch (TYPE(codec_id_or_name)) {
          case T_FIXNUM:
          case T_BIGNUM:
            codec = avcodec_find_encoder(NUM2INT(codec_id_or_name));
            break;
          default:
            codec_id_or_name = rb_str_to_str(codec_id_or_name);
            name = StringValueCStr(codec_id_or_name);
            codec = avcodec_find_encoder_by_name(name);
        }

        if (codec == NULL) return Qnil;

        obj = Data_Wrap_Struct(self, 0, 0, codec);

        rb_funcall(obj, rb_intern("initialize"), 0);

        return obj;
      }
    C

    ##
    # :singleton-method: from

    builder.c_singleton <<-C
      VALUE from(VALUE codec_context_obj) {
        AVCodecContext *codec_context;
        AVCodec *codec;
        VALUE obj;

        Data_Get_Struct(codec_context_obj, AVCodecContext, codec_context);

        codec = codec_context->codec;

        if (codec == NULL) return Qnil;

        obj = Data_Wrap_Struct(self, 0, NULL, codec);

        rb_funcall(obj, rb_intern("initialize"), 1, codec_context);

        return obj;
      }
    C

    ##
    # :method: next

    builder.c <<-C
      VALUE next() {
        AVCodec *codec;

        Data_Get_Struct(self, AVCodec, codec);

        return Data_Wrap_Struct(CLASS_OF(self), NULL, NULL, codec->next);
      }
    C

    ##
    # :method: pixel_formats

    builder.c <<-C
      VALUE pixel_formats() {
        AVCodec * codec;
        volatile VALUE a = Qnil;

        Data_Get_Struct(self, AVCodec, codec);

        if (codec && codec->pix_fmts) {
          const enum PixelFormat * p = codec->pix_fmts;

          a = rb_ary_new();

          for(; *p != -1; p++)
            rb_ary_push(a, INT2FIX(*p));
        }

        return a;
      }
    C

    ##
    # :method: supported_framerates

    builder.c <<-C
      VALUE supported_framerates()
      {
        AVCodec * codec;
        volatile VALUE a = Qnil;

        Data_Get_Struct(self, AVCodec, codec);

        if (codec && codec->supported_framerates) {
          int i = 0;
          AVRational p, *framerate;
          a = rb_ary_new();

          for(;; i++) {
            p = codec->supported_framerates[i];

            if (p.num == 0 && p.den == 0)
              break;

            framerate = av_mallocz(sizeof(AVRational));
            framerate->num = p.num;
            framerate->den = p.den;
            
            rb_ary_push(a,
                        Data_Wrap_Struct(rb_path2class("FFMPEG::Rational"),
                                         NULL, NULL, framerate));
          }
        }

        return a;
      }
    C

    builder.struct_name = 'AVCodec'
    builder.reader :id, 'int'
    builder.reader :capabilities, 'int'

    builder.accessor :name, 'char *'
    builder.accessor :long_name, 'char *'
    builder.accessor :_type, 'int', :type

    builder.map_c_const :CODEC_CAP_DRAW_HORIZ_BAND  => ['int', :DRAW_HORIZ_BAND]
    builder.map_c_const :CODEC_CAP_DR1              => ['int', :DR1]
    builder.map_c_const :CODEC_CAP_PARSE_ONLY       => ['int', :PARSE_ONLY]
    builder.map_c_const :CODEC_CAP_TRUNCATED        => ['int', :TRUNCATED]
    builder.map_c_const :CODEC_CAP_HWACCEL          => ['int', :HWACCEL]
    builder.map_c_const :CODEC_CAP_DELAY            => ['int', :DELAY]
    builder.map_c_const :CODEC_CAP_SMALL_LAST_FRAME => ['int', :SMALL_LAST_FRAME]
    builder.map_c_const :CODEC_CAP_HWACCEL_VDPAU    => ['int', :HWACCEL_VDPAU]
  end

  def initialize(codec_context=nil)
    @codec_context = codec_context
  end

  def type
    self.class.type_name _type
  end

  def inspect
    "#<%s %s:%s>" % [self.class, type, name]
  end

end

