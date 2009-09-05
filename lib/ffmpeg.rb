require 'rubygems'
require 'inline'

##
# HACK use rb_ivar_get

module FFMPEG

  VERSION = '1.0'

  class Error < RuntimeError; end

  class IOError            < Error; end
  class InvalidDataError   < Error; end
  class NoMemError         < Error; end
  class NotSupportedError  < Error; end
  class NumExpectedError   < Error; end
  class PatchWelcomeError  < Error; end
  class UnknownError       < Error; end
  class UnknownFormatError < Error; end

  class Rational; end

  def self.builder_defaults(builder)
    if false then # MacPorts
      builder.add_compile_flags '-I/opt/local/include'
      builder.include '<ffmpeg/avcodec.h>'
      builder.include "<ffmpeg/avformat.h>\n#ifdef RSHIFT\n#undef RSHIFT\n#endif"
      builder.add_link_flags '-L/opt/local/lib/ -lavformat -lavcodec'
    else
      builder.add_compile_flags '-I/opt/ffmpeg/include'
      builder.include '<libavcodec/avcodec.h>'
      builder.include "<libavformat/avformat.h>\n#ifdef RSHIFT\n#undef RSHIFT\n#endif"
      builder.include "<libswscale/swscale.h>"
      builder.add_link_flags '-read_only_relocs suppress -L/opt/ffmpeg/lib/ -lswscale -lavformat -lavcodec -lavutil'
    end

    builder.include_ruby_last

    builder.prefix <<-C
      #ifndef __EXT__
      #define __EXT__

      AVRational *ffmpeg_obj2rat(VALUE object);
      VALUE ffmpeg_rat2obj(AVRational *rational);

      typedef struct FrameBuffer {
        uint8_t * buf;
        int size;
      } FrameBuffer;

      #endif
    C

    builder.alias_type_converter 'long long', 'int64_t'
    builder.add_type_converter 'AVRational', 'ffmpeg_obj2rat', 'ffmpeg_rat2obj'
  end

  inline :C do |builder|
    FFMPEG.builder_defaults builder

    builder.prefix <<-C
      AVRational *ffmpeg_obj2rat(VALUE object) {
        AVRational *rational;

        Data_Get_Struct(object, AVRational, rational);

        return rational;
      }

      VALUE ffmpeg_rat2obj(AVRational *rational) {
        VALUE klass;

        klass = rb_path2class("FFMPEG::Rational");

        return Data_Wrap_Struct(klass, 0, NULL, rational);
      }

      void ffmpeg_check_error(int e) {
        VALUE error_class;
        if (e >= 0) return;

        switch (e) {
        case AVERROR_EOF:
          error_class = rb_eEOFError;
          rb_raise(error_class, "end of file");
          break;
        case AVERROR_IO:
          error_class = rb_path2class("FFMPEG::IOError");
          rb_raise(error_class, "IO error");
          break;
        case AVERROR_NOENT:
          errno = ENOENT;
          rb_sys_fail("");
          break;
        case AVERROR_NOFMT:
          error_class = rb_path2class("FFMPEG::UnknownFormatError");
          rb_raise(error_class, "unknown format");
          break;
        case AVERROR_NOMEM:
          error_class = rb_path2class("FFMPEG::NoMemError");
          rb_raise(error_class, "not enough memory");
          break;
        case AVERROR_NOTSUPP:
          error_class = rb_path2class("FFMPEG::NotSupportedError");
          rb_raise(error_class, "operation not supported");
          break;
        case AVERROR_NUMEXPECTED:
          error_class = rb_path2class("FFMPEG::NumExpectedError");
          rb_raise(error_class, "number syntax expected in filename");
          break;
        case AVERROR_PATCHWELCOME:
          error_class = rb_path2class("FFMPEG::PatchWelcomeError");
          rb_raise(error_class, "not yet implemented in FFMPEG, patches welcome");
          break;
        case AVERROR_UNKNOWN:
        default:
          error_class = rb_path2class("FFMPEG::UnknownError");
          rb_raise(error_class, "unknown error (%d)", e);
        }
      }
    C

    builder.add_to_init <<-C
      av_register_all();
      AVRational *time_base_q;
      time_base_q = (AVRational *)malloc(sizeof(AVRational));
      time_base_q->num = AV_TIME_BASE_Q.num;
      time_base_q->den = AV_TIME_BASE_Q.den;

      rb_define_const(c, "TIME_BASE_Q", ffmpeg_rat2obj(time_base_q));
    C

    builder.map_c_const 'AV_TIME_BASE'       => ['int',     :TIME_BASE]
    builder.map_c_const 'URL_WRONLY'         =>  'int'
    builder.map_c_const 'AV_NOPTS_VALUE'     => ['int64_t', :NOPTS_VALUE]
    builder.map_c_const 'FF_MIN_BUFFER_SIZE' => ['int',     :MIN_BUFFER_SIZE]
  end

end

require 'ffmpeg/rational'
require 'ffmpeg/frame_buffer'
require 'ffmpeg/format_context'
require 'ffmpeg/format_parameters'
require 'ffmpeg/frame'
require 'ffmpeg/input_format'
require 'ffmpeg/output_format'
require 'ffmpeg/packet'
require 'ffmpeg/stream'
require 'ffmpeg/codec_context'
require 'ffmpeg/codec'
require 'ffmpeg/codec/flag'
require 'ffmpeg/codec/flag2'
require 'ffmpeg/codec/id'
require 'ffmpeg/image_scaler'
require 'ffmpeg/stream_map'
require 'ffmpeg/pixel_format'
require 'ffmpeg/sample_format'
require 'ffmpeg/fifo'

if ENV['DEBUG_FFMPEG_RB'] then
  begin
    require 'ruby-debug'
    Debugger.start
    Debugger.settings[:autoeval] = true if Debugger.respond_to?(:settings)
    warn "debugger enabled"
  rescue LoadError
    warn 'not able to load ruby debug'
  end
end

