class FFMPEG::FormatParameters
  inline :C do |builder|
    FFMPEG.builder_defaults builder

    builder.prefix <<-C
      void free_format_parameters(AVFormatParameters* format_parameters)
      {
        av_free(format_parameters);
      }
    C

    ##
    # :singleton-method: allocate

    builder.c_singleton <<-C
      VALUE allocate() {
        AVFormatParameters *format_parameters;
        VALUE obj;

        format_parameters = av_mallocz(sizeof(AVFormatParameters));

        if (!format_parameters)
          rb_raise(rb_eNoMemError, "unable to allocate AVFormatParameters");

        obj = Data_Wrap_Struct(self, NULL, free_format_parameters, format_parameters);

        return obj;
      }
    C

    FORMAT_PARAMETER_CONSTANTS = [
      'AVFMT_GENERIC_INDEX',
      'AVFMT_GLOBALHEADER',
      'AVFMT_NEEDNUMBER',
      'AVFMT_NOFILE',
      'AVFMT_NOTIMESTAMPS',
      'AVFMT_RAWPICTURE',
      'AVFMT_SHOW_IDS',
      'AVFMT_TS_DISCONT',
      'AVFMT_VARIABLE_FPS',
    ]

    FORMAT_PARAMETER_CONSTANTS.each do |const|
      builder.map_c_const const => ['int', const.sub('AVFMT_', '')]
    end

    builder.struct_name = 'AVFormatParameters'
    builder.accessor :channel,      'int'
    builder.accessor :channels,     'int'
    builder.accessor :height,       'int'
    builder.accessor :pixel_format, 'int', :pix_fmt
    builder.accessor :sample_rate,  'int'
    builder.accessor :width,        'int'

    builder.accessor :standard, 'char *' # TODO need av_strlcpy?
  end
end

