class FFMPEG::FIFO
  inline :C do |builder|
    FFMPEG.builder_defaults builder

    builder.include '<libavutil/fifo.h>'

    ##
    # :singleton-method: allocate

    builder.c_singleton <<-C
      VALUE allocate() {
        AVFifoBuffer *fifo;

        fifo = av_fifo_alloc(0);

        if (!fifo)
          rb_raise(rb_eNoMemError, "could not allocate FFMPEG::FIFO");

        return Data_Wrap_Struct(self, NULL, av_fifo_free, fifo);
      }
    C

    ##
    # :method: drain

    builder.c <<-C
      void drain(int bytes) {
        AVFifoBuffer *fifo;

        Data_Get_Struct(self, AVFifoBuffer, fifo);

        av_fifo_drain(fifo, bytes);
      }
    C

    ##
    # :method: read

    builder.c <<-C
      VALUE read(VALUE buffer, int bytes) {
        AVFifoBuffer *fifo;
        int r;

        buffer = rb_str_to_str(buffer);

        if (RSTRING_LEN(buffer) < bytes)
          rb_raise(rb_eArgError, "read size smaller than buffer");

        Data_Get_Struct(self, AVFifoBuffer, fifo);
        
        r = av_fifo_generic_read(fifo, (void *)RSTRING_PTR(buffer), bytes,
                                 NULL);

        return buffer;
      }
    C

    ##
    # :method: realloc

    builder.c <<-C, :method_name => :realloc
      int fifo_realloc(unsigned int bytes) {
        AVFifoBuffer *fifo;
        int ret;

        Data_Get_Struct(self, AVFifoBuffer, fifo);

        ret = av_fifo_realloc2(fifo, bytes);

        if (ret < 0)
          rb_raise(rb_path2class("FFMPEG::Error"), "unable to reallocate fifo");

        return ret;
      }
    C

    ##
    # :method: reset

    builder.c <<-C
      void reset() {
        AVFifoBuffer *fifo;

        Data_Get_Struct(self, AVFifoBuffer, fifo);

        av_fifo_reset(fifo);
      }
    C

    ##
    # :method: size

    builder.c <<-C
      int size() {
        AVFifoBuffer *fifo;

        Data_Get_Struct(self, AVFifoBuffer, fifo);

        return av_fifo_size(fifo);
      }
    C

    ##
    # :method: space

    builder.c <<-C
      int space() {
        AVFifoBuffer *fifo;

        Data_Get_Struct(self, AVFifoBuffer, fifo);

        return av_fifo_space(fifo);
      }
    C

    ##
    # :method: write

    builder.c <<-C
      int write(VALUE buffer) {
        AVFifoBuffer *fifo;
        int written;

        Data_Get_Struct(self, AVFifoBuffer, fifo);
        
        written = av_fifo_generic_write(fifo, (void *)RSTRING_PTR(buffer),
                                        (int)RSTRING_LEN(buffer), NULL);

        return written;
      }
    C

  end

  def initialize(bytes)
    realloc bytes
  end

  def inspect # :nodoc:
    '#<%s:0x%x size %d space %d>' % [self.class, object_id, size, space]
  end

end

