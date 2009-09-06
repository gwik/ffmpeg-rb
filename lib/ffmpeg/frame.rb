class FFMPEG::Frame
  inline :C do |builder|
    FFMPEG.builder_defaults builder

    builder.prefix <<-C
      static void free_frame(AVFrame * frame) {
        if (frame->data[0] && frame->type == FF_BUFFER_TYPE_USER) {
          av_free(frame->data[0]);
        }
        av_free(frame);
      }

      VALUE build_from_avframe_no_free(AVFrame * frame) {
        VALUE klass = rb_path2class("FFMPEG::Frame");
        VALUE obj;

        obj = Data_Wrap_Struct(klass, 0, NULL, frame);

        return obj;
      }

      VALUE build_frame(AVFrame * frame) {
        VALUE klass = rb_path2class("FFMPEG::Frame");
        VALUE obj;

        obj = Data_Wrap_Struct(klass, 0, free_frame, frame);

        return obj;
      }
    C

    ##
    # :singleton-method: allocate

    builder.c_singleton <<-C
      VALUE allocate() {
        AVFrame *frame;
        VALUE obj;

        frame = avcodec_alloc_frame();

        if (!frame)
          rb_raise(rb_eNoMemError, "unable to allocate AVFrame");

        frame->data[0] = NULL;
        frame->data[1] = NULL;
        frame->data[2] = NULL;
        frame->data[3] = NULL;

        obj = Data_Wrap_Struct(self, 0, free_frame, frame);

        return obj;
      }
    C

    ##
    # :method: defaults

    builder.c <<-C
      VALUE defaults() {
        AVFrame *frame;

        Data_Get_Struct(self, AVFrame, frame);

        avcodec_get_frame_defaults(frame);

        return self;
      }
    C

    ##
    # :method: key_frame

    builder.c <<-C
      VALUE key_frame() {
        AVFrame *frame;
        Data_Get_Struct(self, AVFrame, frame);

        if (frame->key_frame)
          return Qtrue;

        return Qfalse;
      }
    C

    ##
    # :method: fill

    builder.c <<-C
      VALUE fill() {
        AVFrame *frame;
        Data_Get_Struct(self, AVFrame, frame);
        int e;

        VALUE pix_fmt = rb_iv_get(self, "@pixel_format");
        VALUE width = rb_iv_get(self, "@width");
        VALUE height = rb_iv_get(self, "@height");

        if (!FIXNUM_P(pix_fmt))
          rb_raise(rb_eRuntimeError, "invalid pixel_format, cannot fill");
        if (!FIXNUM_P(width))
          rb_raise(rb_eRuntimeError, "invalid width, cannot fill");
        if (!FIXNUM_P(height))
          rb_raise(rb_eRuntimeError, "invalid height, cannot fill");

        // free data if needed
        if (frame->data[0] && frame->type == FF_BUFFER_TYPE_USER)
          av_freep(frame->data[0]);

        avcodec_get_frame_defaults(frame);
        frame->type = FF_BUFFER_TYPE_USER;

        e = avpicture_alloc((AVPicture*)frame, FIX2INT(pix_fmt),
                            FIX2INT(width), FIX2INT(height));

        if (e != 0)
          rb_raise(rb_path2class("FFMPEG::Error"), "unable to fill frame");

        return self;
      }
    C

    builder.struct_name = 'AVFrame'
    builder.accessor :picture_type, 'int', :pict_type
    builder.accessor :pts,          'int64_t'
    builder.accessor :quality,      'int'

    builder.map_c_const 'FF_I_TYPE'  => ['int', :I_TYPE]
    builder.map_c_const 'FF_P_TYPE'  => ['int', :P_TYPE]
    builder.map_c_const 'FF_B_TYPE'  => ['int', :B_TYPE]
    builder.map_c_const 'FF_S_TYPE'  => ['int', :S_TYPE]
    builder.map_c_const 'FF_SI_TYPE' => ['int', :SI_TYPE]
    builder.map_c_const 'FF_SP_TYPE' => ['int', :SP_TYPE]
    builder.map_c_const 'FF_BI_TYPE' => ['int', :BI_TYPE]
  end

  attr_accessor :height
  attr_accessor :pixel_format
  attr_accessor :width

  def self.from(codec_context)
    new codec_context.width, codec_context.height, codec_context.pixel_format
  end

  def initialize(width = nil, height = nil, pixel_format = nil)
    @height = height
    @width = width

    @pixel_format = pixel_format
  end

  def type
    case picture_type
    when I_TYPE  then :I_TYPE
    when P_TYPE  then :P_TYPE
    when B_TYPE  then :B_TYPE
    when S_TYPE  then :S_TYPE
    when SI_TYPE then :S_TYPE
    when SP_TYPE then :SP_TYPE
    when BI_TYPE then :BI_TYPE
    end
  end

  alias :key_frame? :key_frame

end

