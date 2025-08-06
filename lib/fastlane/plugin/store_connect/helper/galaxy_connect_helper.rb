require 'fastlane_core/ui/ui'
require 'json'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class GalaxyConnectHelper
      def self.connection
        require 'faraday'
        require 'faraday_middleware'

        options = {
          url: "https://devapi.samsungapps.com",
          request: {
            timeout: 1200,
            open_timeout: 180
          }
        }

        logger = Logger.new($stderr)
        logger.level = Logger::DEBUG

        Faraday.new(options) do |builder|
          builder.request(:multipart)
          builder.request(:json)
          builder.request(:url_encoded)
          builder.response(:json, content_type: /\bjson$/)
          builder.response(:logger, logger)
          builder.use(FaradayMiddleware::FollowRedirects)
          builder.adapter(:net_http)
        end
      end

      def self.generate_jwt_token(account_id, private_key_path)
        require 'jwt'
        require 'time'

        iat = Time.now.to_i
        payload = { iss: account_id, scopes: ['publishing', 'gss'], iat: iat, exp: iat + 1200 }
        private_key = OpenSSL::PKey::RSA.new(File.read(private_key_path))
        token = JWT.encode(payload, private_key, 'RS256')
        return token
      end

      def self.get_token(account_id, private_key_path)
        jwt_token = generate_jwt_token(account_id, private_key_path)
        url = "/auth/accessToken"
        response = connection.post(url) do |req|
          req.headers['Authorization'] = "Bearer #{jwt_token}"
        end
        if response.status == 200
          return response.body["createdItem"]["accessToken"]
        else
          raise "get_token --> #{response.status}"
        end
      end

      def self.update_release_notes(token, account_id, content_id, ru_release_notes_path, en_release_notes_path)
        ru_release_notes = File.read(ru_release_notes_path)
        en_release_notes = File.read(en_release_notes_path)
        url = "/seller/contentUpdate"
        response = connection.post(url) do |req|
          req.headers['Authorization'] = "Bearer #{token}"
          req.headers['service-account-id'] = account_id
          req.body = {
            contentId: content_id,
            defaultLanguageCode: "ENG",
            paid: "N",
            publicationType: "01",
            newFeature: en_release_notes,
            addLanguage: [{ languagecode: "RUS", newFeature: ru_release_notes}]
          }
        end
        if response.status == 200
          if response.body["contentStatus"] == "REGISTERING" && response.body["status"] == "OK"
            UI.message("update_release_notes --> OK")
          else
            raise "update_release_notes --> #{response.body}"
          end
        else
          raise "update_release_notes --> #{response.status}"
        end
      end

      def self.get_binary_seq_for_delete(token, account_id, content_id)
        url = "/seller/contentInfo?contentId=#{content_id}"
        response = connection.get(url) do |req|
          req.headers['Authorization'] = "Bearer #{token}"
          req.headers['service-account-id'] = account_id
        end
        if response.status == 200
          return response.body[0]["binaryList"][0]["binarySeq"]
        else
          raise "get_binary_seq_for_delete --> #{response.status}"
        end
      end

      def self.delete_old_aabs(token, account_id, content_id)
        binary_seq = get_binary_seq_for_delete(token, account_id, content_id)
        url = "/seller/v2/content/binary?contentId=#{content_id}&binarySeq=#{binary_seq}"
        response = connection.delete(url)
        if response.status == 200
          if response.body["resultMessage"] == "Ok"
            UI.message("delete_old_aabs --> OK")
          else
            raise "delete_old_aabs --> #{response.body}"
          end
        else
          raise "delete_old_aabs --> #{response.status}"
        end
      end

      def self.get_upload_sessionId()
        url = "/seller/createUploadSessionId"
        response = connection.post(url)
        if response.status == 200
          return response.body["sessionId"]
        else
          raise "get_upload_sessionId --> #{response.status}"
        end
      end

      def self.upload_file(token, account_id, file_path)
        session_id = get_upload_sessionId()
        url = "/galaxyapi/fileUpload"
        response = connection.post(url) do |req|
          req.headers['Authorization'] = "Bearer #{token}"
          req.headers['service-account-id'] = account_id
          req.body = { sessionId: session_id, file: Faraday::Multipart::FilePart.new(file_path, 'application/x-authorware-bin') }
        end
        if response.status == 200
          return response.body["fileKey"]
        else
          raise "upload_file --> #{response.status}"
        end
      end

      def self.upload_aab_google(token, account_id, content_id, aab_google_path)
        file_key = upload_file(token, account_id, aab_google_path)
        url = "seller/v2/content/binary"
        response = connection.post(url) do |req|
          req.body = { contentId: content_id, gms: "Y", filekey: file_key }
        end
        if response.status == 200
          if response.body["resultMessage"] == "Ok"
            UI.message("update_release_notes --> OK")
          else
            raise "update_release_notes --> #{response.body}"
          end
        else
          raise "update_release_notes --> #{response.status}"
        end
      end

      def self.submit(token, account_id, content_id)
        url = "/seller/contentSubmit"
        response = connection.post(url) do |req|
          req.headers['Authorization'] = "Bearer #{token}"
          req.headers['service-account-id'] = account_id
          req.body = { contentId: content_id }
        end
        if response.status == 204
          UI.message("submit --> OK")
        else
          raise "submit --> #{response.status}"
        end
      end
    end
  end
end
