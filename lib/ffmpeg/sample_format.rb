class FFMPEG::SampleFormat
  inline :C do |builder|
    FFMPEG.builder_defaults builder

    SAMPLE_FORMAT_CONSTANTS = {
      'SAMPLE_FMT_DBL' => 'double',
      'SAMPLE_FMT_FLT' => 'float',
      'SAMPLE_FMT_S16' => 'signed 16 bits',
      'SAMPLE_FMT_S32' => 'signed 32 bits',
      'SAMPLE_FMT_U8'  => 'unsigned 8 bits',
    }

    SAMPLE_FORMAT_CONSTANTS.each do |const, desc|
      builder.map_c_const const => ['int', const.sub('SAMPLE_FMT_', '')]
    end
  end

  FORMATS = {}

  SAMPLE_FORMAT_CONSTANTS.each do |const, desc|
    FORMATS[const_get(const.sub('SAMPLE_FMT_', ''))] = desc
  end

end

