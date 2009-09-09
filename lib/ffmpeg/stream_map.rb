class FFMPEG::StreamMap

  attr_reader :input_format_context
  attr_reader :map
  attr_reader :output_format_contexts

  def initialize(input_format_context)
    @input_format_context = input_format_context
    @output_format_contexts = []
    @map = {}
  end

  def add(in_stream, out_stream)
    raise ArgumentError, 'input and output stream types differ' unless
      in_stream.type == out_stream.type

    unless in_stream.format_context == @input_format_context then
      raise ArgumentError,
            'input stream must belong to input format context'
    end

    if out_stream.format_context.input? then
      raise ArgumentError,
            'output stream must belong to an output format context'
    end

    @output_format_contexts << out_stream.format_context unless
      @output_format_contexts.include? out_stream.format_context

    (@map[in_stream.stream_index] ||= []) << out_stream
  end

  def empty?
    @map.empty?
  end

end

