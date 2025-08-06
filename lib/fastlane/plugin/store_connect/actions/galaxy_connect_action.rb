require 'fastlane/action'
require_relative '../helper/galaxy_connect_helper'

module Fastlane
  module Actions
    class GalaxyConnectAction < Action
      def self.run(params)
        content_id = params[:content_id]
        account_id_path = params[:account_id_path]
        account_id = File.read(account_id_path)
        private_key_path = params[:private_key_path]
        aab_google_path = params[:aab_google_path]
        ru_release_notes_path = params[:ru_release_notes_path]
        en_release_notes_path = params[:en_release_notes_path]
        # Получение авторизационного токена.
        token = Helper::GalaxyConnectHelper.get_token(account_id, private_key_path)
        # Добавление описания.
        Helper::GalaxyConnectHelper.update_release_notes(token, account_id, content_id, ru_release_notes_path, en_release_notes_path)
        # Удаление старого файла aab.
        elper::GalaxyConnectHelper.delete_old_aabs(token, account_id, content_id)
        # Добавление нового файла aab.
        Helper::GalaxyConnectHelper.upload_aab_google(token, account_id, content_id, aab_google_path)
        # Отправка на ревью.
        Helper::GalaxyConnectHelper.submit(token, account_id, content_id)
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
          FastlaneCore::ConfigItem.new(key: :content_id,
                                  env_name: "GALAXY_CONTENT_ID",
                               description: "Уникальный код приложения в сторе",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :account_id_path,
                                  env_name: "GALAXY_ACCOUNT_ID_PATH",
                               description: "Путь до файла с идентификатором аккаунта galaxy",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :private_key_path,
                                  env_name: "GALAXY_PRIVATE_KEY_PATH",
                               description: "Путь до файла с приватным ключом galaxy",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :aab_google_path,
                                  env_name: "GALAXY_AAB_GOOGLE_PATH",
                               description: "Путь до файла aab с google-сервисами",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :ru_release_notes_path,
                                  env_name: "GALAXY_RU_RELEASE_NOTES_PATH",
                               description: "Путь до файла с описанием «New Feature»",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :en_release_notes_path,
                                  env_name: "GALAXY_EN_RELEASE_NOTES_PATH",
                               description: "Путь до файла с описанием «New Feature»",
                                  optional: false,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
