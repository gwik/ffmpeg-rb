module FFMPEG
  class FrameBuffer
    inline :C do |builder|
      FFMPEG.builder_defaults builder
      
      builder.prefix <<-C
        static free_frame_buffer(FrameBuffer * buf) {
          fprintf(stderr, "free buffer\\n");
          if (buf->ptr != NULL)
            *(buf->ptr) = NULL;
          
          if (buf->buf) {
            fprintf(stderr, "buffer %p\\n", buf->buf);
            av_free(buf->buf);
          }
          
          av_free(buf);
          fprintf(stderr, "buffer freed %p\\n", buf);
        }
      C
      
      ##
      # :method: build_from_packet
      
      builder.c_singleton <<-C
        VALUE build_from_packet(VALUE rb_packet) {
          AVPacket * packet;
          Data_Get_Struct(rb_packet, AVPacket, packet);
          
          FrameBuffer * frame_buffer;
          frame_buffer = av_mallocz(sizeof(FrameBuffer));
          frame_buffer->buf = packet->data;
          frame_buffer->size = packet->size;
          frame_buffer->ptr = (void **) &(packet->data);
          return Data_Wrap_Struct(self, 0, free_frame_buffer, frame_buffer);
        }
      C
      
      ##
      # :method: new

      builder.c_singleton <<-C
        VALUE new(int size) {
          FrameBuffer * frame_buf;
          
          frame_buf = av_malloc(sizeof(FrameBuffer));
          frame_buf->size = size;
          frame_buf->buf = av_mallocz(size);
          
          return Data_Wrap_Struct(self, 0, free_frame_buffer, frame_buf);
        }
      C
      
      ##
      # :method: clean
      
      builder.c <<-C
        VALUE clean() {
          FrameBuffer * frame_buf;
          Data_Get_Struct(self, FrameBuffer, frame_buf);
          
          if (frame_buf->buf)
            av_freep(frame_buf->buf);
          if (frame_buf->ptr != NULL)
            *(frame_buf->ptr) = NULL;
          
          frame_buf->buf = av_mallocz(frame_buf->size);
          
          return self;
        }
      C
      
      builder.struct_name = 'FrameBuffer'
      
      builder.accessor :size, 'int'
    end
    
    def initialize(size)
    end
    
  end
end
