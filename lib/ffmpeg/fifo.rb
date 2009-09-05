class FFMPEG::FIFO
  inline :C do |builder|
    FFMPEG.builder_defaults builder

    builder.include '<libavutil/fifo.h>'

    ##
    # :singleton-method: allocate

    builder.c_singleton <<-C
      VALUE allocate() {
        return Data_Wrap_Struct(self, NULL, av_fifo_free, NULL);
      }
    C

    ##
    # :method: initialize

    builder.c <<-C
      void initialize(unsigned int bytes) {
        AVFifoBuffer *fifo;

        Data_Get_Struct(self, AVFifoBuffer, fifo);

        fifo = av_fifo_alloc(bytes);

        if (!fifo)
          rb_raise(rb_eNoMemError, "could not allocate FFMPEG::FIFO");
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
    # :method: realloc2

    builder.c <<-C
      int realloc2(unsigned int bytes) {
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
  end
end

