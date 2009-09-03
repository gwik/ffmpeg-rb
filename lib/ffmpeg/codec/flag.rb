class FFMPEG::Codec::Flag
  inline :C do |builder|
    FFMPEG.builder_defaults builder

    FLAG_CONSTANTS = [
      'CODEC_FLAG_AC_PRED',
      'CODEC_FLAG_ALT_SCAN',
      'CODEC_FLAG_BITEXACT',
      'CODEC_FLAG_CBP_RD',
      'CODEC_FLAG_CLOSED_GOP',
      'CODEC_FLAG_EMU_EDGE',
      'CODEC_FLAG_EXTERN_HUFF',
      'CODEC_FLAG_GLOBAL_HEADER',
      'CODEC_FLAG_GMC',
      'CODEC_FLAG_GRAY',
      'CODEC_FLAG_H263P_AIV',
      'CODEC_FLAG_H263P_SLICE_STRUCT',
      'CODEC_FLAG_H263P_UMV',
      'CODEC_FLAG_INPUT_PRESERVED',
      'CODEC_FLAG_INTERLACED_DCT',
      'CODEC_FLAG_INTERLACED_ME',
      'CODEC_FLAG_LOOP_FILTER',
      'CODEC_FLAG_LOW_DELAY',
      'CODEC_FLAG_MV0',
      'CODEC_FLAG_NORMALIZE_AQP',
      'CODEC_FLAG_OBMC',
      'CODEC_FLAG_PART',
      'CODEC_FLAG_PASS1',
      'CODEC_FLAG_PASS2',
      'CODEC_FLAG_PSNR',
      'CODEC_FLAG_QPEL',
      'CODEC_FLAG_QP_RD',
      'CODEC_FLAG_QSCALE',
      'CODEC_FLAG_SVCD_SCAN_OFFSET',
      'CODEC_FLAG_TRUNCATED',
    ]
    
    FLAG_CONSTANTS.each do |const|
      builder.map_c_const const => ['int', const.sub('CODEC_FLAG_', '')]
    end

    builder.map_c_const 'CODEC_FLAG_4MV' => ['int', 'FOURMV']
  end
end
