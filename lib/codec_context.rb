module FFMPEG
  class CodecContext
    inline :C do |builder|
      FFMPEG.builder_defaults builder

      ##
      # :singleton-method: from

      builder.c_singleton <<-C
        VALUE from(VALUE stream_obj) {
          AVStream *stream;
          VALUE obj;

          Data_Get_Struct(stream_obj, AVStream, stream);

          obj = Data_Wrap_Struct(self, NULL, NULL, stream->codec);

          rb_funcall(obj, rb_intern("initialize"), 0);

          return obj;
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
      # :method: decoder

      builder.c <<-C
        VALUE decoder() {
          VALUE codec_klass;
          AVCodecContext *codec_context;

          Data_Get_Struct(self, AVCodecContext, codec_context);

          codec_klass = rb_path2class("FFMPEG::Codec");

          return rb_funcall(codec_klass, rb_intern("for_decoder"), 1,
                            INT2NUM(codec_context->codec_id));
        }
      C

      ##
      # :method: decode_video

      builder.c <<-C
        VALUE decode_video(VALUE picture, VALUE buf) {
          AVCodecContext *codec_context;
          AVFrame *frame;
          VALUE ret;
          int got_picture = 0;
          int buf_used;

          Data_Get_Struct(self, AVCodecContext, codec_context);
          Data_Get_Struct(picture, AVFrame, frame);

          buf_used = avcodec_decode_video(codec_context, frame, &got_picture,
                                          (uint8_t *)StringValuePtr(buf),
                                          RSTRING_LEN(buf));

          ret = rb_ary_new();
          rb_ary_push(ret, INT2NUM(got_picture));
          rb_ary_push(ret, INT2NUM(buf_used));

          return ret;
        }
      C

      ##
      # :method: encode_video

      builder.c <<-C
        int encode_video(VALUE picture, VALUE buf) {
          AVCodecContext *codec_context;
          AVFrame *frame;
          int buf_used;

          Data_Get_Struct(self, AVCodecContext, codec_context);
        
          if (NIL_P(picture)) {
            frame = NULL;
          } else {
            Data_Get_Struct(picture, AVFrame, frame);
          }

          buf_used = avcodec_encode_video(codec_context,
                                          (uint8_t *)StringValuePtr(buf),
                                          RSTRING_LEN(buf), frame);

          return buf_used;
        }
      C

      ##
      # :method: encoder

      builder.c <<-C
        VALUE encoder() {
          VALUE codec_klass;
          AVCodecContext *codec_context;

          Data_Get_Struct(self, AVCodecContext, codec_context);

          codec_klass = rb_path2class("FFMPEG::Codec");

          return rb_funcall(codec_klass, rb_intern("for_encoder"), 1,
                            INT2NUM(codec_context->codec_id));
        }
      C

      ##
      # :method: open

      builder.c <<-C
        VALUE open(VALUE _codec) {
          AVCodecContext *codec_context;
          AVCodec *codec;
          int err;

          Data_Get_Struct(self, AVCodecContext, codec_context);
          Data_Get_Struct(_codec, AVCodec, codec);

          err = avcodec_open(codec_context, codec);

          if (err < 0) {
            rb_raise(rb_eRuntimeError, "error opening codec: %d.  Check bit_rate, rate, width, height", err);
          }

          return self;
        }
      C

      builder.struct_name = 'AVCodecContext'

      builder.accessor :bit_rate,                    'int'
      builder.accessor :bit_rate_tolerance,          'int'
      builder.accessor :height,                      'int'
      builder.accessor :pix_fmt,                     'int'
      builder.accessor :gop_size,                    'int'
      builder.accessor :rc_buffer_size,              'int'
      builder.accessor :rc_initial_buffer_occupancy, 'int'
      builder.accessor :width,                       'int'

      builder.reader :channels,    'int'
      builder.reader :codec_id,    'int'
      builder.reader :_codec_type, 'int', :codec_type
      builder.reader :sample_rate, 'int'


      builder.reader :codec_name, 'char *'

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
      # :method: defaults
      
      builder.c <<-C
        VALUE defaults() {
          AVCodecContext *pointer;
          Data_Get_Struct(self, AVCodecContext, pointer);
          
          avcodec_get_context_defaults2(pointer, pointer->codec_type);
          return self;
        }
      C
      
    end

    def codec_type
      FFMPEG::Codec.type_name _codec_type
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
end
