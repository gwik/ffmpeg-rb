require 'ffmpeg'

file = ARGV.shift
file ||= File.expand_path '../../test/Thumbs Up!.3gp', __FILE__

begin
  input = FFMPEG::FormatContext.new file
rescue FFMPEG::UnknownFormatError
  puts "Unknown file format for #{File.basename file}"
  exit
end

puts "#{File.basename file} metadata:"
puts 'album:     %p' % input.album
puts 'author:    %p' % input.author
puts 'comment:   %p' % input.comment
puts 'copyright: %p' % input.copyright
puts 'filename:  %p' % input.filename
puts 'genre:     %p' % input.genre
puts 'title:     %p' % input.title
puts

