describe Fastlane::Actions::RustoreConnectAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The rustore_connect plugin is working!")

      Fastlane::Actions::RustoreConnectAction.run(nil)
    end
  end
end

describe Fastlane::Actions::AppgalleryConnectAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The appgallery_connect plugin is working!")

      Fastlane::Actions::AppgalleryConnectAction.run(nil)
    end
  end
end

describe Fastlane::Actions::GalaxyConnectAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The galaxy_connect plugin is working!")

      Fastlane::Actions::GalaxyConnectAction.run(nil)
    end
  end
end
