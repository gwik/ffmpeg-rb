module FFMPEG
  
  class ImageScaler
    inline :C do |builder|
      FFMPEG.builder_defaults builder
      
      builder.prefix %q|
        static void free_sws_context(struct SwsContext * sws_context) {
          sws_freeContext(sws_context);
        }
      |
      
      builder.c_singleton <<-C
        VALUE new(VALUE origin_width, VALUE origin_height, VALUE origin_pix_fmt,
                  VALUE dest_width, VALUE dest_height, VALUE dest_pix_fmt, VALUE sws_flags)
        {
          VALUE klass = rb_path2class("FFMPEG::ImageScaler");
          struct SwsContext * sws_context = sws_getContext(
                            NUM2INT(origin_width),
                            NUM2INT(origin_height),
                            NUM2INT(origin_pix_fmt),
                            NUM2INT(dest_width),
                            NUM2INT(dest_height),
                            NUM2INT(dest_pix_fmt),
                            NUM2INT(sws_flags), NULL, NULL, NULL);
          
          VALUE obj = Data_Wrap_Struct(klass, 0, free_sws_context, sws_context);
          
          rb_funcall(obj, rb_intern("initialize"), 7, origin_width, origin_height, 
                    origin_pix_fmt, dest_width, dest_height, dest_pix_fmt, sws_flags);
          
          return obj;
        }
      C
      
      builder.c <<-C
        VALUE scale(VALUE rb_in_frame) {
          struct SwsContext * img_convert_ctx;
          AVFrame * in_frame;
          AVFrame * out_frame;
          VALUE frame_klass = rb_path2class("FFMPEG::Frame");
          
          VALUE rb_out_frame = rb_funcall(frame_klass, rb_intern("new"), 3,
            rb_iv_get(self, "@dest_width"),
            rb_iv_get(self, "@dest_height"),
            rb_iv_get(self, "@dest_pix_fmt"));
          
          rb_funcall(rb_out_frame, rb_intern("fill"), 0);
          
          Data_Get_Struct(self, struct SwsContext, img_convert_ctx);
          Data_Get_Struct(rb_in_frame, AVFrame, in_frame);
          Data_Get_Struct(rb_out_frame, AVFrame, out_frame);
          
          if (NULL == in_frame->data[0])
            return rb_out_frame;
                    
          sws_scale(img_convert_ctx, in_frame->data, in_frame->linesize,
                    0, FIX2INT(rb_iv_get(self, "@origin_height")),
                    out_frame->data, out_frame->linesize);
          
          return rb_out_frame;
        }
      C
      
      builder.struct_name = 'struct SwsContext'
      builder.map_c_const 'SWS_BICUBIC' => ['int', :BICUBIC]
    end
    
    def initialize(origin_width, origin_height, origin_pix_fmt, dest_width, 
        dest_height, dest_pix_fmt, flags)
      @origin_width, @origin_height, @origin_pix_fmt = origin_width, origin_height, origin_pix_fmt
      @dest_width, @dest_height, @dest_pix_fmt = dest_width, dest_height, dest_pix_fmt
      @flags = flags
    end
    
  end
  
  
end
