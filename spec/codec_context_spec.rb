require File.dirname(__FILE__) + '/spec_helper'

describe FFMPEG::CodecContext do
  
  describe "video input stream codec context" do
    
    before :each do
      @iformat = FFMPEG::FormatContext.new($test_file)
      @codec_context = @iformat.video_stream.codec_context
    end
    
    describe "attributes methods" do
      
      it "has a non-zero bitrate" do
        @codec_context.should respond_to(:bit_rate)
        @codec_context.bit_rate.should be_kind_of(Numeric)
        @codec_context.bit_rate.should_not be_zero
      end
      
      it "has a non minus 1 pixel format" do
        @codec_context.should respond_to(:pixel_format)
        @codec_context.pixel_format.should be_kind_of(Numeric)
        @codec_context.pixel_format.should_not == -1
      end
      
      it "has a non-zero group of picture size" do
        @codec_context.should respond_to(:gop_size)
        @codec_context.gop_size.should be_kind_of(Numeric)
        @codec_context.height.should_not be_zero
      end
      
      it "has a non-zero height" do
        @codec_context.should respond_to(:height)
        @codec_context.height.should be_kind_of(Numeric)
        @codec_context.height.should_not be_zero
      end
      
      it "has a non-zero width" do
        @codec_context.should respond_to(:height)
        @codec_context.height.should be_kind_of(Numeric)
        @codec_context.height.should_not be_zero
      end
    
      it "has a non-zero codec_id" do
        @codec_context.should respond_to(:codec_id)
        @codec_context.codec_id.should be_kind_of(Numeric)
        @codec_context.height.should_not be_zero
      end
    
      it "has a codec_name" do
        @codec_context.should respond_to(:codec_name)
        @codec_context.codec_name.should be_instance_of(String)
      end
    
      it "has a codec (nil until opened)" do
        @codec_context.should respond_to(:codec)
        @codec_context.codec.should be_nil
      end
    
      it "has a codec :VIDEO type" do
        @codec_context.should respond_to(:codec_type)
        @codec_context.codec_type.should be_instance_of(Symbol)
        @codec_context.codec_type.should == :VIDEO
      end
      
      it "has a non-zero time base" do
        @codec_context.should respond_to(:time_base)
        @codec_context.time_base.should be_instance_of(FFMPEG::Rational)
      end
      
    end
    
    describe "opening codecs" do
      
      it "find its decoder codec" do
        @codec_context.decoder.should be_instance_of(FFMPEG::Codec)
      end
      
      it "open decoder" do
        lambda do
          @codec_context.open(@codec_context.decoder)
        end.should_not raise_error
        
        @codec_context.codec.should be_instance_of(FFMPEG::Codec)
      end
      
    end
    
  end
end