Gem::Specification.new do |spec|
  spec.name = 'ffmpeg-rb'
  spec.version = '0.0.1'
  spec.summary = 'Ruby C bindings to ffmpeg/libav* library with RubyInline'
  spec.authors = ["Eric Hodel", "Antonin Amand"]
  spec.email = 'antonin.amand@gmail.com'
  spec.files = Dir['**/*.rb']
  spec.homepage = 'http://github.com/gwik/ffmpeg-rb'
  spec.require_path = '.'
  spec.has_rdoc = false
  spec.date = Time.now
  spec.requirements << <<-END
    Last ffmpeg libraries compiled with lib swscale.
  END
  spec.add_dependency('RubyInline', '>= 3.8.1')
end
