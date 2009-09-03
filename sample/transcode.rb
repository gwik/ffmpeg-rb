require 'ffmpeg'

file = File.expand_path '../../test/Thumbs Up!.3gp', __FILE__

input = FFMPEG::FormatContext.new file
input_video_steam = input.video_stream

flv = FFMPEG::FormatContext.new 'Thumbs Up!.flv', true
#mp4 = FFMPEG::FormatContext.new 'Thumbs Up!.mp4', true

flv_stream = flv.new_output_video_stream('flv', :bit_rate => 1_000_000,
                                         :width => 300, :height => 200,
                                         :fps => FFMPEG.Rational(25, 1))

#mp4_stream = mp4.new_output_video_stream('mpeg4', :bit_rate => 2_000_000,
#                                         :width => 640, :height => 480,
#                                         :gop_size => 12,
#                                         :fps => FFMPEG.Rational(25,1))

input.transcode_map do |stream_map|
  stream_map.add input_video_steam, flv_stream
  #stream_map.add input_video_steam, mp4_stream
end

# input.transcode 'mp4', 'mpeg4', 'mp3', "out.mp4"

