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
    # :method: data

    builder.c <<-C
      VALUE data() {
        AVFrame *frame;
        VALUE ary;
        int data_size, i;
        char *data, *ptr;

        Data_Get_Struct(self, AVFrame, frame);

        if (!frame->data)
          return Qnil;

        data_size = NUM2INT(rb_funcall(self, rb_intern("data_size"), 0));
        ary = rb_ary_new2(4);

        if (frame->data[0]) {
          data = (char *)frame->data[0];
          rb_ary_store(ary, 0, rb_str_new(data, data_size));

          for (i = 1; i < 4; i++) {
            ptr = (char *)frame->data[i];

            if (ptr) {
              rb_ary_store(ary, i,
                           rb_str_new(ptr, data_size + data - ptr));
            } else {
              rb_ary_store(ary, i, Qnil);
            }

          }
        } else {
          for (i = 1; i < 4; i++)
            rb_ary_store(ary, i, Qnil);
        }

        return ary;
      }
    C

    ##
    # :method: data=

    builder.c <<-C
      void data_equals(VALUE input) {
        AVFrame *frame;
        VALUE ff_error = rb_path2class("FFMPEG::Error");
        VALUE row;
        int data_size, i;

        input = rb_ary_to_ary(input);

        if (RARRAY_LEN(input) != 4)
          rb_raise(rb_eArgError,
                   "data must be of length 4 (was %d)", RARRAY_LEN(input));

        Data_Get_Struct(self, AVFrame, frame);

        if (!frame->data)
          rb_raise(ff_error, "unfilled frame");

        row = rb_ary_entry(input, 0);
        row = rb_str_to_str(row);

        data_size = NUM2INT(rb_funcall(self, rb_intern("data_size"), 0));

        if (RSTRING_LEN(row) != data_size)
          rb_raise(rb_eArgError,
                   "data size mismatch (%d expected, was %d)",
                   data_size, RSTRING_LEN(row));

        memcpy(frame->data[0], RSTRING_PTR(row), RSTRING_LEN(row));

        for (i = 1; i < 4; i++) {
          if (frame->data[i]) {
            row = rb_ary_entry(input, i);

            if (NIL_P(row))
              continue;

            row = rb_str_to_str(row);

            memcpy(frame->data[i], RSTRING_PTR(row),
                   data_size + frame->data[0] - frame->data[i]);
          }
        }
      }
    C

    ##
    # :method: data_size

    builder.c <<-C
      int data_size() {
        AVPicture picture;
        int size;

        VALUE width   = rb_iv_get(self, "@width");
        VALUE height  = rb_iv_get(self, "@height");
        VALUE pix_fmt = rb_iv_get(self, "@pixel_format");

        if (!FIXNUM_P(width))
          rb_raise(rb_eRuntimeError, "invalid width, cannot size");
        if (!FIXNUM_P(height))
          rb_raise(rb_eRuntimeError, "invalid height, cannot size");
        if (!FIXNUM_P(pix_fmt))
          rb_raise(rb_eRuntimeError, "invalid pixel_format, cannot size");

        size = avpicture_fill(&picture, NULL, FIX2INT(pix_fmt),
                           FIX2INT(width), FIX2INT(height));

        if (size < 0)
          rb_raise(rb_path2class("FFMPEG::Error"), "unable to get size");

        return size;
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
    # :method: linesize

    builder.c <<-C
      VALUE linesize() {
        AVFrame *frame;
        VALUE ary;
        int i;

        Data_Get_Struct(self, AVFrame, frame);

        if (!frame->data)
          return Qnil;

        ary = rb_ary_new2(4);

        for (i = 0; i < 4; i++) {
          rb_ary_store(ary, i, INT2NUM(frame->linesize[i]));
        }

        return ary;
      }
    C

    ##
    # :method: fill

    builder.c <<-C
      VALUE fill() {
        AVFrame *frame;
        Data_Get_Struct(self, AVFrame, frame);
        int e, i;

        VALUE width   = rb_iv_get(self, "@width");
        VALUE height  = rb_iv_get(self, "@height");
        VALUE pix_fmt = rb_iv_get(self, "@pixel_format");

        if (!FIXNUM_P(width))
          rb_raise(rb_eRuntimeError, "invalid width, cannot fill");
        if (!FIXNUM_P(height))
          rb_raise(rb_eRuntimeError, "invalid height, cannot fill");
        if (!FIXNUM_P(pix_fmt))
          rb_raise(rb_eRuntimeError, "invalid pixel_format, cannot fill");

        // free data if needed
        if (frame->data[0] && frame->type == FF_BUFFER_TYPE_USER) {
          av_freep(frame->data[0]);

          for (i = 0; i < 4; i++)
            frame->data[i] = NULL;
          for (i = 0; i < 4; i++)
            frame->linesize[i] = 0;
        }

        avcodec_get_frame_defaults(frame);
        frame->type = FF_BUFFER_TYPE_USER;

        e = avpicture_alloc((AVPicture *)frame, FIX2INT(pix_fmt),
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
  attr_accessor :width
  attr_accessor :pixel_format

  def self.from(codec_context)
    new codec_context.width, codec_context.height, codec_context.pixel_format
  end

  def initialize(width = nil, height = nil, pixel_format = nil)
    @height = height
    @width = width

    @pixel_format = pixel_format
  end

  def clear
    self.data = ["\000" * data_size, nil, nil, nil]
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

