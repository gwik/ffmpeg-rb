module FFMPEG
  class Frame
    inline :C do |builder|
      FFMPEG.builder_defaults builder
      
      builder.prefix %q|
        static void free_frame(AVFrame * frame) {
          //fprintf(stderr, "free frame %p\n", frame);
          if (frame->data[0] && frame->type == FF_BUFFER_TYPE_USER) {
            //fprintf(stderr, "free frame data\n");
            av_free(frame->data[0]);
          }
          av_free(frame);
          //fprintf(stderr, "frame freed\n");
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
        
      |
      
      ##
      # :singleton-method: allocate

      builder.c_singleton <<-C
        VALUE allocate() {
          AVFrame *frame;
          VALUE obj;

          frame = avcodec_alloc_frame();
          frame->data[0] = NULL;
          frame->data[1] = NULL;
          frame->data[2] = NULL;
          frame->data[3] = NULL;
          
          if (!frame)
            rb_raise(rb_eNoMemError, "unable to allocate AVFrame");
            
          // fprintf(stderr, "alloc frame %p\\n", frame);

          obj = Data_Wrap_Struct(self, 0, free_frame, frame);

          return obj;
        }
      C
      
      # builder.c_singleton <<-C
      #   VALUE build(int width, int height, int pix_fmt) {
      #     AVFrame *picture;
      #     uint8_t *picture_buf;
      #     int size;
      # 
      #     picture = avcodec_alloc_frame();
      #     if (!picture)
      #         return NULL;
      #     
      #     size = avpicture_get_size(pix_fmt, width, height);
      #     
      #     picture_buf = av_malloc(size);
      #     if (!picture_buf) {
      #         av_free(picture);
      #         rb_raise(rb_eNoMemError, "could not allocate picture");
      #     }
      #     avpicture_fill((AVPicture *)picture, picture_buf,
      #         pix_fmt, width, height);
      #     
      #     VALUE obj = Data_Wrap_Struct(self, 0, free_frame, picture);
      #     rb_funcall(obj, rb_intern("initialize"), 3, width, height, pix_fmt);
      #     
      #     return obj;
      #   }
      # C
      
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
      
      builder.c <<-C
        VALUE key_frame() {
          AVFrame *frame;
          Data_Get_Struct(self, AVFrame, frame);
          
          if (frame->key_frame)
            return Qtrue;
          
          return Qfalse;
        }
      C
      
      builder.c <<-C
        VALUE fill() {
          AVFrame *frame;
          Data_Get_Struct(self, AVFrame, frame);

          VALUE pix_fmt = rb_iv_get(self, "@pix_fmt");
          VALUE width = rb_iv_get(self, "@width");
          VALUE height = rb_iv_get(self, "@height");
          
          if (!FIXNUM_P(pix_fmt))
            rb_raise(rb_eRuntimeError, "pix_fmt not set properly cannot fill");
          if (!FIXNUM_P(width))
            rb_raise(rb_eRuntimeError, "width not set properly cannot fill");
          if (!FIXNUM_P(height))
            rb_raise(rb_eRuntimeError, "height not set properly cannot fill");
          
          // free data if needed
          if (frame->data[0] && frame->type == FF_BUFFER_TYPE_USER)
            av_freep(frame->data[0]);
          
          avcodec_get_frame_defaults(frame);
          frame->type = FF_BUFFER_TYPE_USER;
          
          avpicture_alloc((AVPicture*)frame,
                             FIX2INT(pix_fmt),
                             FIX2INT(width),
                             FIX2INT(height));
          
          return self;
        }
      C
      
      builder.struct_name = 'AVFrame'
      builder.accessor :pts, 'int64_t'
      builder.accessor :quality, 'int'
      builder.reader   :pict_type, 'int'
      
      builder.map_c_const 'FF_I_TYPE'  => ['int', :I_TYPE]
      builder.map_c_const 'FF_P_TYPE'  => ['int', :P_TYPE]
      builder.map_c_const 'FF_B_TYPE'  => ['int', :B_TYPE]
      builder.map_c_const 'FF_S_TYPE'  => ['int', :S_TYPE]
      builder.map_c_const 'FF_SI_TYPE' => ['int', :SI_TYPE]
      builder.map_c_const 'FF_SP_TYPE' => ['int', :SP_TYPE]
      builder.map_c_const 'FF_BI_TYPE' => ['int', :BI_TYPE]
    end
    
    attr_accessor :width, :height, :pix_fmt
    
    def initialize(width=nil, height=nil, pix_fmt=nil)
      @width, @height, @pix_fmt = width, height, pix_fmt
    end
    
    def type
      case pict_type
      when I_TYPE ; :I_TYPE
      when P_TYPE ; :P_TYPE
      when B_TYPE ; :B_TYPE
      when S_TYPE ; :S_TYPE
      when SI_TYPE ; :S_TYPE
      when SP_TYPE ; :SP_TYPE
      when BI_TYPE ; :BI_TYPE
      end
    end
    
    alias :key_frame? :key_frame
    
  end
end
