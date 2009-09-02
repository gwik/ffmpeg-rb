module FFMPEG
  
  class InvalidMap < StandardError
  end
  
  # stream_map = StreamMap.new(input_format)
  # stream_map.map(input_format.video_stream, output_format.out_stream)
  # stream_map.map(input_format.audio_stream, output_format2.audio_stream)
  # stream_map.map(input_format.video_stream, output_format3.video_stream)
  # stream_map.map(input_format.audio_stream, output_format3.audio_stream)
  class StreamMap
    
    attr_reader :map, :input_format_context, :output_format_contexts
    
    def initialize(input_format_context)
      @input_format_context = input_format_context
      @output_format_contexts = []
      @map = {}
    end
    
    def add(in_stream, out_stream)
      raise InvalidMap.new("stream type differs") unless in_stream.type == out_stream.type
      raise InvalidMap.new("invalid stream : no format context") unless
        out_stream.format_context
      raise InvalidMap.new("input stream must belongs to input format context") unless
        in_stream.format_context == @input_format_context
      
      @output_format_contexts << out_stream.format_context unless
        @output_format_contexts.include?(out_stream.format_context)
      (@map[in_stream.stream_index] ||= []) << out_stream
    end
    
    def empty?
      @map.keys.empty?
    end
    
  end
  
end
