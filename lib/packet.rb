module FFMPEG
  class Packet
    inline :C do |builder|
      FFMPEG.builder_defaults builder
      
      builder.prefix %q|
        void free_packet(AVPacket * packet) {
          // fprintf(stderr, "free packet\n");
          av_free(packet);
          // fprintf(stderr, "packet freed\n");
        }
      |
      
      ##
      # :singleton-method: allocate

      builder.c_singleton <<-C
        VALUE allocate() {
          AVPacket * packet;
          VALUE obj;

          packet = av_mallocz(sizeof(AVPacket));
          
          if (!packet)
            rb_raise(rb_eNoMemError, "unable to allocate AVPacket");
          
          packet->pts   = AV_NOPTS_VALUE;
          packet->dts   = AV_NOPTS_VALUE;
          packet->pos   = -1;
          
          obj = Data_Wrap_Struct(self, 0, free_packet, packet);

          return obj;
        }
      C

      ##
      # :method: buffer

      builder.c <<-C
        VALUE buffer() {
          AVPacket* packet;

          Data_Get_Struct(self, AVPacket, packet);

          return rb_str_new((char *)packet->data, packet->size);
        }
      C

      ##
      # :method: buffer=

      builder.c <<-C
        VALUE buffer_equals(VALUE buffer) {
          AVPacket* packet;

          Data_Get_Struct(self, AVPacket, packet);
          rb_iv_set(self, "@buffer", buffer);
          
          packet->data = (unsigned char *)StringValuePtr(buffer);
          packet->size = RSTRING_LEN(buffer);
          
          fprintf(stderr, "data buffer %p\\n", packet->data);
          
          return buffer;
        }
      C
      
      ##
      # :method: clean
      
      builder.c <<-C
        VALUE clean() {
          AVPacket* packet;
          Data_Get_Struct(self, AVPacket, packet);
          
          av_init_packet(packet);
          
          return self;
        }
      C

      builder.struct_name = 'AVPacket'
      builder.accessor :duration,             'int'
      builder.accessor :flags,                'int'
      builder.accessor :convergence_duration, 'int'
      builder.accessor :size,                 'int'
      builder.accessor :stream_index,         'int'

      builder.accessor :dts, 'int64_t'
      builder.accessor :pos, 'int64_t'
      builder.accessor :pts, 'int64_t'
      
      builder.map_c_const 'PKT_FLAG_KEY' => ['int', :FLAG_KEY]
    end
    
    alias :stream_index= :stream_index_equals
  end
    
end
