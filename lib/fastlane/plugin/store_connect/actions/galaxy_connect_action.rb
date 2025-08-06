require 'fastlane/action'
require_relative '../helper/galaxy_connect_helper'

module Fastlane
  module Actions
    class GalaxyConnectAction < Action
      def self.run(params)
        UI.message("The galaxy_connect plugin is working!")
      end

      def self.description
        "Publish to Galaxy"
      end

      def self.authors
        ["Mariia Bazhina"]
      end

      def self.details
        "Plugin allows to publish aab with google services to Galaxy"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "STORE_CONNECT_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
