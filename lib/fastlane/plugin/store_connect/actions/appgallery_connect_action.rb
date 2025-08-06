require 'fastlane/action'
require_relative '../helper/appgallery_connect_helper'

module Fastlane
  module Actions
    class AppgalleryConnectAction < Action
      def self.run(params)
        client_id = params[:client_id]
        client_secret = params[:client_secret]
        app_id = params[:app_id]
        aab_hms_path = params[:aab_hms_path]
        message_for_moderator_path = params[:message_for_moderator_path]
        release_notes_path = params[:release_notes_path]
        release_percent = params[:release_percent]

        # Получение авторизационного токена.
        token = Helper::AppgalleryConnectHelper.get_token(client_id, client_secret)

        if token.nil?
          UI.message("Cannot retrieve token, please check your client ID and client secret")
        else
          Helper::AppgalleryConnectHelper.update_release_notes(token, client_id, app_id, release_notes_path)

          upload_app = Helper::AppgalleryConnectHelper.upload_app(token, client_id, app_id, aab_hms_path)

          UI.message("Waiting 10 seconds for upload to get processed...")
          sleep(10)

          self.submit_for_review(token, upload_app, client_id, app_id, message_for_moderator_path, release_notes_path, release_percent)
        end
      end

      def self.submit_for_review(token, upload_app, client_id, app_id, message_for_moderator_path, release_notes_path, release_percent)
        if upload_app["success"] == true
          compilationStatus = Helper::AppgalleryConnectHelper.query_aab_compilation_status(token, client_id, app_id, upload_app["pkgVersion"])
          if compilationStatus == 1
            UI.important("aab file is currently processing, waiting for 2 minutes...")
            sleep(120)
            self.submit_for_review(token, upload_app, client_id, app_id, message_for_moderator_path, release_notes_path, release_percent)
          elsif compilationStatus == 2
            Helper::AppgalleryConnectHelper.submit_app_for_review(token, client_id, app_id, message_for_moderator_path, release_notes_path, release_percent)
          else
            UI.user_error!("Compilation of aab failed")
          end
        end
      end

      def self.description
        "Publish to Appgallery"
      end

      def self.authors
        ["Mariia Bazhina"]
      end

      def self.details
        "Plugin allows to publish aab with hms services to Appgallery"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :client_id,
                                  env_name: "APPGALLERY_CLIENT_ID",
                               description: "Huawei AppGallery Connect Client ID",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :client_secret,
                                  env_name: "APPGALLERY_CLIENT_SECRET",
                               description: "Huawei AppGallery Connect Client Secret",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :app_id,
                                  env_name: "APPGALLERY_APP_ID",
                               description: "Huawei AppGallery Connect App ID",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :aab_hms_path,
                                  env_name: "APPGALLERY_AAB_PATH",
                               description: "Путь до файла aab с hms-сервисами",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :message_for_moderator_path,
                                  env_name: "APPGALLERY_MESSAGE_FOR_MODERATOR_PATH",
                               description: "Путь до файла с сообщением для модератора",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :release_notes_path,
                                  env_name: "APPGALLERY_RELEASE_NOTES_PATH",
                               description: "Путь до файла с описанием «Новые функции»",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :release_percent,
                                  env_name: "APPGALLERY_RELEASE_PERCENT",
                               description: "Процент для частичной публикации приложения",
                                  optional: false,
                                      type: Integer)

        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
