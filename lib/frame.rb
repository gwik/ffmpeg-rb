module FFMPEG
  class Frame
    inline :C do |builder|
      FFMPEG.builder_defaults builder
      
      builder.prefix <<-C
        void free_frame(AVFrame * frame) {
          av_free(frame->data[0]);
          av_free(frame);
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

          obj = Data_Wrap_Struct(self, free_frame, NULL, frame);

          return obj;
        }
      C
      
      builder.c_singleton <<-C
        VALUE build(int width, int height, int pix_fmt) {
          AVFrame *picture;
          uint8_t *picture_buf;
          int size;

          picture = avcodec_alloc_frame();
          if (!picture)
              return NULL;
          
          size = avpicture_get_size(pix_fmt, width, height);
          
          picture_buf = av_malloc(size);
          if (!picture_buf) {
              av_free(picture);
              rb_raise(rb_eNoMemError, "could not allocate picture");
          }
          avpicture_fill((AVPicture *)picture, picture_buf,
              pix_fmt, width, height);
          
          VALUE obj = Data_Wrap_Struct(self, free_frame, NULL, picture);
          rb_funcall(obj, rb_intern("initialize"), 3, width, height, pix_fmt);
          
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
      builder.accessor :pts, 'int64_t'
    end
    
    attr_accessor :width, :height, :pix_fmt
    
    def initialize(width=nil, height=nil, pix_fmt=nil)
      @width, @height, @pix_fmt = width, height, pix_fmt
    end
  end
end
