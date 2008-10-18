module FFMPEG
  class Frame
    inline :C do |builder|
      FFMPEG.builder_defaults builder

      ##
      # :singleton-method: allocate

      builder.c_singleton <<-C
        VALUE allocate() {
          AVFrame *frame;
          VALUE obj;

          frame = malloc(sizeof(AVFrame));

          if (!frame)
            rb_raise(rb_eNoMemError, "unable to allocate AVFrame");

          obj = Data_Wrap_Struct(self, NULL, NULL, frame);

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

      builder.struct_name = 'AVFrame'
      builder.reader :pts, 'int64_t'
    end
  end
end
