require 'spec_helper'

describe FFMPEG::Codec do
  describe "Class methods" do
    describe "for_encoder" do
      it "finds encoder by id" do
        FFMPEG::Codec.for_encoder(1).should be_instance_of(FFMPEG::Codec)
      end

      it "finds encoder by name" do
        FFMPEG::Codec.for_encoder("mpeg1video").should be_instance_of(FFMPEG::Codec)
      end

      it "return nil when not found" do
        FFMPEG::Codec.for_encoder("gloobyboulga").should be_nil
      end
    end

    describe "for_decoder" do
      it "finds decoder by id" do
        FFMPEG::Codec.for_decoder(1).should be_instance_of(FFMPEG::Codec)
      end

      it "finds decoder by name" do
        FFMPEG::Codec.for_decoder("mpeg1video").should be_instance_of(FFMPEG::Codec)
      end

      it "return nil when not found" do
        FFMPEG::Codec.for_decoder("gloobyboulga").should be_nil
      end
    end
  end
end

