module FFMPEG
  class Codec
    inline :C do |builder|
      FFMPEG.builder_defaults builder
      
      CONSTS = [
        [:UNKNOWN,    :CODEC_TYPE_UNKNOWN,    :int],
        [:VIDEO,      :CODEC_TYPE_VIDEO,      :int],
        [:AUDIO,      :CODEC_TYPE_AUDIO,      :int],
        [:DATA,       :CODEC_TYPE_DATA,       :int],
        [:SUBTITLE,   :CODEC_TYPE_SUBTITLE,   :int],
        [:ATTACHMENT, :CODEC_TYPE_ATTACHMENT, :int],
        [:NB,         :CODEC_TYPE_NB,         :int],
      ]
      
      CONSTS.each do |name, c_name, c_type|
        builder.map_c_const c_name => [c_type, name]
      end
      
      def self.type_name(type)
        CONSTS.find do |name, c_name, c_type|
          type == self.const_get(name)
        end.first
      end
      
      ##
      # :singleton-method: for_decoder
      builder.c_singleton <<-C
        VALUE for_decoder(VALUE codec_id_or_name) {
          AVCodec *codec;
          char *name;
          VALUE obj;
          
          switch (TYPE(codec_id_or_name)) {
            case T_FIXNUM:
            case T_BIGNUM:
              codec = avcodec_find_decoder(NUM2INT(codec_id_or_name));
              break;
            default:
              codec_id_or_name = rb_str_to_str(codec_id_or_name);
              name = StringValueCStr(codec_id_or_name);
              codec = avcodec_find_decoder_by_name(name);
          }
          
          if (codec == NULL) return Qnil;
            
          obj = Data_Wrap_Struct(self, 0, 0, codec);
          
          rb_funcall(obj, rb_intern("initialize"), 0);
          
          return obj;
        }
      C
      
      ##
      # :singleton-method: for_encoder
      
      builder.c_singleton <<-C
        VALUE for_encoder(VALUE codec_id_or_name) {
          AVCodec *codec;
          char *name;
          VALUE obj;
          
          switch (TYPE(codec_id_or_name)) {
            case T_FIXNUM:
            case T_BIGNUM:
              codec = avcodec_find_encoder(NUM2INT(codec_id_or_name));
              break;
            default:
              codec_id_or_name = rb_str_to_str(codec_id_or_name);
              name = StringValueCStr(codec_id_or_name);
              codec = avcodec_find_encoder_by_name(name);
          }
          
          if (codec == NULL) return Qnil;
          
          obj = Data_Wrap_Struct(self, 0, 0, codec);
          
          rb_funcall(obj, rb_intern("initialize"), 0);
          
          return obj;
        }
      C
      
      ##
      # :singleton-method: from
      
      builder.c_singleton <<-C
        VALUE from(VALUE codec_context_obj) {
          AVCodecContext *codec_context;
          AVCodec *codec;
          VALUE obj;
          
          Data_Get_Struct(codec_context_obj, AVCodecContext, codec_context);
          
          codec = codec_context->codec;
          
          if (codec == NULL) return Qnil;
          
          obj = Data_Wrap_Struct(self, 0, NULL, codec);
          
          rb_funcall(obj, rb_intern("initialize"), 1, codec_context);
          
          return obj;
        }
      C
      
      builder.struct_name = 'AVCodec'
      builder.accessor :name, 'char *'
      
      builder.accessor :_type, 'int', :type
    end
    
    def initialize(codec_context=nil)
      @codec_context = nil
    end
    
    def type
      self.class.type_name _type
    end
    
    def inspect
      "#<%s %s:%s>" % [self.class, type, name]
    end
    
  end
end
