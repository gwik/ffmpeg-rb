module FFMPEG
  class Packet
    inline :C do |builder|
      FFMPEG.builder_defaults builder
      
      builder.prefix %q|
        void free_packet(AVPacket * packet) {
          fprintf(stderr, "free packet\n");
          //av_destruct_packet(packet);
          fprintf(stderr, "packet freed\n");
        }
      |
      
      ##
      # :singleton-method: allocate

      builder.c_singleton <<-C
        VALUE allocate() {
          AVPacket *packet;
          VALUE obj;

          packet = av_malloc(sizeof(AVPacket));
          
          if (!packet)
            rb_raise(rb_eNoMemError, "unable to allocate AVPacket");
          
          packet->pts   = AV_NOPTS_VALUE;
          packet->dts   = AV_NOPTS_VALUE;
          packet->pos   = -1;
          packet->duration = 0;
          packet->convergence_duration = 0;
          packet->flags = 0;
          packet->stream_index = 0;
          
          obj = Data_Wrap_Struct(self, free_packet, 0, packet);

          return obj;
        }
      C

      ##
      # :method: buffer

      builder.c <<-C
        VALUE buffer() {
          AVPacket* packet;

          Data_Get_Struct(self, AVPacket, packet);

          return rb_str_new((char *)packet->data, packet->size + FF_INPUT_BUFFER_PADDING_SIZE);
        }
      C

      ##
      # :method: buffer=

      builder.c <<-C
        VALUE buffer_equals(VALUE buffer) {
          AVPacket* packet;

          Data_Get_Struct(self, AVPacket, packet);

          packet->data = (unsigned char *)StringValuePtr(buffer);
          packet->size = RSTRING_LEN(buffer);

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
