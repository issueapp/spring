require 'spec_helper'
require 'pp'
require 'local_issue/page'
require 'local_issue/page_helpers'

describe "Page helpers" do
  class Renderer
    include LocalIssue::PageHelpers
  end
  
  let(:view) { Renderer.new }
    
  # let(:page) { LocalIssue::Page.new(
  #   images: [ media ],
  #   content: "<div><img data-media-id='images:1'/></div>"
  # )}
  #   
  describe "Image element" do
    let(:node) { view.create_element('img', 'data-media-id' => 'images:1') }
    
    let(:media) { {
      "url" => "new_images/audio.png", 
      "caption" => "caption text",
      "caption_inset" => true
    }}
      
    it "render image block around figure" do
      view.image_node(node, media).to_s.should include "<figure>"
    end
    
    it "renders captions in figcaption tag" do
      output = view.image_node(node, "caption" => "caption text").to_s
      
      output.should include "<figcaption>caption text</figcaption>"
    end
    
    it "adds inset class" do
      output = view.image_node(node, "caption" => "ho la", "caption_inset" => true).to_s
      output.should include '<figcaption class="inset">ho la</figcaption>'
    end
  end
  
  describe "Video element" do
    let(:media) { {
      "url" => "assets/to/video.mp4",
      "caption" => "video introduction"
    }}
    
    let(:node) { view.create_element('video', 'data-media-id' => 'videos:1') }
    
    it "render video block around figure" do
      output = view.video_node(node, media).to_s
      output.should include '<figure class="video">'
    end
    
    it "renders youtube video via iframe" do
      output = view.video_node(node, media.merge("url" => 'https://www.youtube.com/watch?v=pTjS0o-ZIRg')).to_s
      
      output.should include "<iframe"
      output.should include 'src="http://youtube.com/embed/pTjS0o-ZIRg'
    end

    it "renders vimeo video via iframe" do
      output = view.video_node(node, media.merge("url" => 'http://vimeo.com/92354665')).to_s
      
      output.should include "<iframe"
      output.should include 'src="http://player.vimeo.com/video/92354665'
    end
        
    it "might have custom thumbnail" do
      output = view.video_node(node, media.merge("thumb_url" => "assets/preview.jpg")).to_s
      
      output.should include 'poster="assets/preview.jpg"'
    end
    
    it "adds playback attribute: :autoplay, :muted, :controls" do
      output = view.video_node(node, media.merge("autoplay" => true, "controls" => true)).to_s
      
      output.should match %r{<video src="assets/to/video.mp4"([^>]+)autoplay([^>]+)controls([^>]+)>}
    end
    
    it "adds caption" do
      output = view.video_node(node, media.merge("caption" => "something")).to_s
      output.should include "<figcaption>something</figcaption>"
    end
  end
  
  describe "Audio element" do
    let(:media) { {
      "url" => "assets/song.mp3",
      "caption" => "a thousands miles"
    }}
    let(:node) { view.create_element('audio', 'data-media-id' => 'audios:1') }
    
    it "render video block around figure" do
      output = view.audio_node(node, media).to_s
      output.should include '<figure class="audio">'
    end
    
    it "adds playback attribute: :autoplay, :muted, :controls" do
      output = view.audio_node(node, media.merge("autoplay" => true, "controls" => true)).to_s
      
      output.should match %r{<audio src="assets/song.mp3"([^>]+)autoplay([^>]+)controls([^>]+)>}
    end
    
    it "might have custom thumbnail" do
      output = view.audio_node(node, media.merge("thumb_url" => "assets/album.jpg")).to_s
      
      output.should include '<img class="thumbnail" src="assets/album.jpg"'
    end
  end
  
end