module FFMPEG
  class OutputFormat
    inline :C do |builder|
      FFMPEG.builder_defaults builder

      builder.map_c_const :AVFMT_NOOUTPUTLOOP => [:int, :NO_OUTPUT_LOOP]

      ##
      # :singleton-method: from

      builder.c_singleton <<-C
        VALUE from(VALUE ffmpeg) {
          AVFormatContext *format_context;
          VALUE obj;

          Data_Get_Struct(ffmpeg, AVFormatContext, format_context);

          if (format_context->oformat == NULL) return Qnil;

          obj = Data_Wrap_Struct(self, 0, NULL, format_context->oformat);

          rb_funcall(obj, rb_intern("initialize"), 0);

          return obj;
        }
      C

      ##
      # :singleton-method: guess_format

      builder.c_singleton <<-C, :method_name => :guess_format
        VALUE of_guess_format(VALUE _short_name, VALUE _file_name,
                              VALUE _mime_type) {
          AVOutputFormat *output_format;
          VALUE obj, output_format_klass;
          char *short_name = NULL;
          char *file_name = NULL;
          char *mime_type = NULL;

          if (RTEST(_short_name)) {
            short_name = StringValueCStr(_short_name);
          }

          if (RTEST(_file_name)) {
            file_name = StringValueCStr(_file_name);
          }

          if (RTEST(_mime_type)) {
            mime_type = StringValueCStr(_mime_type);
          }
 
          output_format = guess_format(short_name, file_name, mime_type);

          if (!output_format) {
            rb_raise(rb_eArgError, "error determining output format (guess_format)");
          }

          output_format_klass = rb_path2class("FFMPEG::OutputFormat");

          obj = Data_Wrap_Struct(output_format_klass, NULL, NULL, output_format);

          return obj;
        }
      C

      ##
      # :method: guess_codec

      builder.c <<-C, :method_name => :guess_codec
        int of_guess_codec(VALUE _shortname, VALUE _filename, VALUE _mimetype,
                           int codec_type) {
          AVOutputFormat *output_format;
          char *shortname = NULL;
          char *filename = NULL;
          char *mimetype = NULL;
          int codec_id;

          Data_Get_Struct(self, AVOutputFormat, output_format);

          if (!NIL_P(_shortname)) shortname = StringValueCStr(_shortname);
          if (!NIL_P(_filename))  filename  = StringValueCStr(_filename);
          if (!NIL_P(_mimetype))  mimetype  = StringValueCStr(_mimetype);

          codec_id = av_guess_codec(output_format, shortname, filename, mimetype,
                                    codec_type);

          return codec_id;
        }
      C

      builder.struct_name = 'AVOutputFormat'
      builder.reader :name,       'char *'
      builder.reader :long_name,  'char *'
      builder.reader :mime_type,  'char *'
      builder.reader :extensions, 'char *'

      builder.reader :flags, 'int'
    end
  end
end
