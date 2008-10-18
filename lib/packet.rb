module FFMPEG
  class Packet
    inline :C do |builder|
      FFMPEG.builder_defaults builder

      ##
      # :singleton-method: allocate

      builder.c_singleton <<-C
        VALUE allocate() {
          AVPacket *packet;
          VALUE obj;

          packet = malloc(sizeof(AVPacket));

          if (!packet)
            rb_raise(rb_eNoMemError, "unable to allocate AVPacket");

          obj = Data_Wrap_Struct(self, NULL, NULL, packet);

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

          packet->data = (unsigned char *)StringValuePtr(buffer);
          packet->size = RSTRING_LEN(buffer);

          return buffer;
        }
      C

      builder.struct_name = 'AVPacket'
      builder.accessor :duration,     'int'
      builder.accessor :flags,        'int'
      builder.accessor :size,         'int'
      builder.accessor :stream_index, 'int'

      builder.accessor :dts, 'int64_t'
      builder.accessor :pos, 'int64_t'
      builder.accessor :pts, 'int64_t'
    end
  end
end
