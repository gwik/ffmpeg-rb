module FFMPEG
  class InputFormat
    inline :C do |builder|
      FFMPEG.builder_defaults builder

      ##
      # :singleton-method: from

      builder.c_singleton <<-C
        VALUE from(VALUE ffmpeg) {
          AVFormatContext *format_context;
          VALUE obj;

          Data_Get_Struct(ffmpeg, AVFormatContext, format_context);

          if (format_context->iformat == NULL) return Qnil;

          obj = Data_Wrap_Struct(self, 0, NULL, format_context->iformat);

          rb_funcall(obj, rb_intern("initialize"), 0);

          return obj;
        }
      C

      builder.struct_name = 'AVInputFormat'
      builder.reader :name,       'char *'
      builder.reader :long_name,  'char *'
      builder.reader :extensions, 'char *'

      builder.reader :flags, 'int'
    end
  end
end