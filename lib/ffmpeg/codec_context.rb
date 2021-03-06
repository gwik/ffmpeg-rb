class FFMPEG::CodecContext
  inline :C do |builder|
    FFMPEG.builder_defaults builder

    ##
    # :singleton-method: from

    builder.c_singleton <<-C
      VALUE from(VALUE stream_obj) {
        AVStream *stream;
        VALUE obj;

        Data_Get_Struct(stream_obj, AVStream, stream);

        obj = Data_Wrap_Struct(self, 0, 0, stream->codec);

        rb_funcall(obj, rb_intern("initialize"), 1, stream_obj);

        return obj;
      }
    C

    ##
    # :method: bits_per_sample

    builder.c <<-C
      int bits_per_sample() {
        AVCodecContext *codec_context;

        Data_Get_Struct(self, AVCodecContext, codec_context);

        return av_get_bits_per_sample_format(codec_context->sample_fmt);
      }
    C

    ##
    # :method: codec

    builder.c <<-C
      VALUE codec()
      {
        AVCodecContext *pointer;
        Data_Get_Struct(self, AVCodecContext, pointer);

        volatile VALUE codec_klass = rb_path2class("FFMPEG::Codec");

        if (pointer->codec == NULL)
          return Qnil;

        return Data_Wrap_Struct(codec_klass, 0, 0, pointer->codec);
      }
    C

    ##
    # :method: coded_frame

    builder.c <<-C
      VALUE coded_frame() {
        AVCodecContext *codec_context;
        VALUE frame_klass;
        VALUE frame = Qnil;

        Data_Get_Struct(self, AVCodecContext, codec_context);

        if (codec_context->coded_frame != NULL) {
          frame_klass = rb_path2class("FFMPEG::Frame");
          frame = build_from_avframe_no_free(codec_context->coded_frame);
        }

        return frame;
      }
    C

    ##
    # :method: decode_audio

    builder.c <<-C
      int decode_audio(VALUE buffer, VALUE packet) {
        AVCodecContext *codec_context;
        AVPacket *pkt;
        int16_t *samples;
        int bytes_used, frame_size;

        if (NIL_P(pkt))
          return Qnil;

        Data_Get_Struct(self, AVCodecContext, codec_context);
        Data_Get_Struct(packet, AVPacket, pkt);

        samples = (int16_t *)RSTRING_PTR(buffer);
        frame_size = RSTRING_LEN(buffer);

        bytes_used = avcodec_decode_audio3(codec_context, samples,
                                           &frame_size, pkt);

        ffmpeg_check_error(bytes_used);

        /* FFMPEG source mentions some codecs seem to overflow */
        if (frame_size < 0)
          frame_size = 0;

        #ifdef rb_str_set_len
        rb_str_set_len(buffer, frame_size);
        #else
        RSTRING(buffer)->len = frame_size;
        #endif

        return bytes_used;
      }
    C

    ##
    # :method: decode_video

    builder.c <<-C
      VALUE decode_video(VALUE picture, VALUE packet) {
        AVCodecContext *codec_context;
        AVFrame *frame;
        AVPacket *pkt;
        volatile VALUE ret;
        int got_picture = 0;
        int buf_used;

        if (NIL_P(pkt))
          return Qnil;

        Data_Get_Struct(self, AVCodecContext, codec_context);
        Data_Get_Struct(picture, AVFrame, frame);
        Data_Get_Struct(packet, AVPacket, pkt);

        buf_used = avcodec_decode_video2(codec_context, frame, &got_picture,
                                         pkt);

        ret = rb_ary_new();
        rb_ary_push(ret, INT2NUM(got_picture));
        rb_ary_push(ret, INT2NUM(buf_used));

        return ret;
      }
    C

    ##
    # :method: defaults

    builder.c <<-C
      VALUE defaults() {
        AVCodecContext *pointer;
        Data_Get_Struct(self, AVCodecContext, pointer);

        avcodec_get_context_defaults2(pointer, pointer->codec_type);

        return self;
      }
    C

    ##
    # :method: encode_audio

    builder.c <<-C
      int encode_audio(VALUE samples, VALUE encoded) {
        AVCodecContext *codec_context;
        int used;

        Data_Get_Struct(self, AVCodecContext, codec_context);

        used = avcodec_encode_audio(codec_context,
                                    (uint8_t *)RSTRING_PTR(encoded),
                                    (int)RSTRING_LEN(encoded),
                                    (const short *)RSTRING_PTR(samples));

        if (used < 0)
          rb_raise(rb_path2class("FFMPEG::Error"), "audio encoding failed");

        rb_str_set_len(encoded, used);

        return used;
      }
    C

    ##
    # :method: encode_video

    builder.c <<-C
      int encode_video(VALUE picture, VALUE buffer) {
        AVCodecContext *codec_context;
        AVFrame *frame;
        int buf_used;
        FrameBuffer * buf;

        Data_Get_Struct(buffer, FrameBuffer, buf);
        Data_Get_Struct(self, AVCodecContext, codec_context);

        if (NIL_P(picture)) {
          frame = NULL;
        } else {
          Data_Get_Struct(picture, AVFrame, frame);
        }

        buf_used = avcodec_encode_video(codec_context,
                                        buf->buf,
                                        buf->size, frame);

        return buf_used;
      }
    C

    ##
    # :method: fps=

    builder.c <<-C
      VALUE fps_equals(VALUE fps_rational)
      {

        AVRational * fps;
        AVRational recalc_fps;

        AVCodecContext *codec_context;

        Data_Get_Struct(fps_rational, AVRational, fps);
        Data_Get_Struct(self, AVCodecContext, codec_context);

        recalc_fps.den = fps->den;
        recalc_fps.num = fps->num;

        AVCodec * codec = codec_context->codec;

        if (codec && codec->supported_framerates)
          recalc_fps = codec->supported_framerates[av_find_nearest_q_idx(recalc_fps, codec->supported_framerates)];

        codec_context->time_base.den = recalc_fps.num;
        codec_context->time_base.num = recalc_fps.den;

        return ffmpeg_rat2obj(&(codec_context->time_base));
      }
    C

    ##
    # :method: open

    builder.c <<-C
      VALUE open(VALUE _codec) {
        AVCodecContext *codec_context;
        AVCodec *codec;
        int e;

        VALUE iv_codec = rb_iv_get(self, "@codec");
        if (!NIL_P(iv_codec))
          return iv_codec;

        Data_Get_Struct(self, AVCodecContext, codec_context);
        Data_Get_Struct(_codec, AVCodec, codec);

        e = avcodec_open(codec_context, codec);

        ffmpeg_check_error(e);

        RDATA(_codec)->dfree = 0;
        rb_iv_set(self, "@codec", _codec);

        return self;
      }
    C

    ##
    # :method: sample_aspect_ratio

    builder.c <<-C
      VALUE sample_aspect_ratio() {
        AVCodecContext *pointer;
        AVRational *sample_aspect_ratio;

        Data_Get_Struct(self, AVCodecContext, pointer);

        sample_aspect_ratio = &(pointer->sample_aspect_ratio);

        return ffmpeg_rat2obj(sample_aspect_ratio);
      }
    C

    ##
    # :method: time_base

    builder.c <<-C
      VALUE time_base() {
        AVCodecContext *pointer;
        AVRational *time_base;

        Data_Get_Struct(self, AVCodecContext, pointer);

        time_base = &(pointer->time_base);

        return ffmpeg_rat2obj(time_base);
      }
    C

    ##
    # :method: time_base=

    builder.c <<-C
      VALUE time_base_equals(VALUE value) {
        AVCodecContext * codec_context;
        Data_Get_Struct(self, AVCodecContext, codec_context);

        codec_context->time_base.num = FIX2INT(rb_funcall(value, rb_intern("num"), 0));
        codec_context->time_base.den = FIX2INT(rb_funcall(value, rb_intern("den"), 0));

        return ffmpeg_rat2obj(&(codec_context->time_base));
      }
    C

    builder.struct_name = 'AVCodecContext'

    builder.accessor :bit_rate,                    'int'
    builder.accessor :bit_rate_tolerance,          'int'
    builder.accessor :channels,                    'int'
    builder.accessor :codec_id,                    'int'
    builder.accessor :gop_size,                    'int'
    builder.accessor :flags,                       'int'
    builder.accessor :flags2,                      'int'
    builder.accessor :height,                      'int'
    builder.accessor :max_b_frames,                'int'
    builder.accessor :pixel_format,                'int', :pix_fmt
    builder.accessor :rc_buffer_size,              'int'
    builder.accessor :rc_initial_buffer_occupancy, 'int'
    builder.accessor :sample_rate,                 'int'
    builder.accessor :width,                       'int'

    builder.reader :_codec_type,   'int', :codec_type
    builder.reader :frame_size,    'int'
    builder.reader :sample_format, 'int', :sample_fmt

    builder.reader :codec_name, 'char *'
  end

  private_class_method :new

  def initialize(stream=nil)
    @stream = stream
  end

  def bytes_per_sample
    bits_per_sample / 8
  end

  def codec_type
    FFMPEG::Codec.type_name _codec_type
  end

  def decoder
    FFMPEG::Codec.for_decoder(codec_id)
  end

  def dimensions
    "#{height}x#{width}"
  end

  def encoder
    FFMPEG::Codec.for_encoder(codec_id)
  end

  def inspect
    "#<%s:%x %s:%s %dx%d %dbps %0.2ffps>" % [
      self.class, object_id,
      codec_type, codec_name,
      width, height,
      bit_rate,
      time_base
    ]
  end

end

