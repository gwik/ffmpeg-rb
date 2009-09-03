class FFMPEG::Codec::Flag
  inline :C do |builder|
    FFMPEG.builder_defaults builder

    FLAG2_CONSTANTS = [
      'CODEC_FLAG2_AUD',
      'CODEC_FLAG2_BIT_RESERVOIR',
      'CODEC_FLAG2_BPYRAMID',
      'CODEC_FLAG2_BRDO',
      'CODEC_FLAG2_CHUNKS',
      'CODEC_FLAG2_DROP_FRAME_TIMECODE',
      'CODEC_FLAG2_FAST',
      'CODEC_FLAG2_FASTPSKIP',
      'CODEC_FLAG2_INTRA_VLC',
      'CODEC_FLAG2_LOCAL_HEADER',
      'CODEC_FLAG2_MEMC_ONLY',
      'CODEC_FLAG2_MIXED_REFS',
      'CODEC_FLAG2_NON_LINEAR_QUANT',
      'CODEC_FLAG2_NO_OUTPUT',
      'CODEC_FLAG2_SKIP_RD',
      'CODEC_FLAG2_STRICT_GOP',
      'CODEC_FLAG2_WPRED',
    ]

    FLAG2_CONSTANTS.each do |const|
      builder.map_c_const const => ['int', const.sub('CODEC_FLAG_', '')]
    end

    builder.map_c_const 'CODEC_FLAG2_8X8DCT' => ['int', 'EIGHTXEIGHTDCT']
  end
end

