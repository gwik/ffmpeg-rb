module FFMPEG
  class FormatParameters
    inline :C do |builder|
      FFMPEG.builder_defaults builder

      ##
      # :singleton-method: allocate

      builder.c_singleton <<-C
        VALUE allocate() {
          AVFormatParameters *format_parameters;
          VALUE obj;

          format_parameters = malloc(sizeof(AVFormatParameters));

          if (!format_parameters)
            rb_raise(rb_eNoMemError, "unable to allocate AVFormatParameters");

          obj = Data_Wrap_Struct(self, NULL, NULL, format_parameters);

          return obj;
        }
      C

    end
  end
end