require 'fastlane_core/ui/ui'
require 'cgi'
require 'time'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class AppgalleryConnectHelper
      def self.get_token(client_id, client_secret)
        UI.important("Fetching app access token")

        uri = URI('https://connect-api.cloud.huawei.com/api/oauth2/v1/token')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        req.body = {client_id: client_id, grant_type: 'client_credentials', client_secret: client_secret }.to_json
        res = http.request(req)

        result_json = JSON.parse(res.body)

        return result_json['access_token']
      end

      def self.upload_app(token, client_id, app_id, aab_path)
        UI.message("Fetching upload URL")

        responseData = JSON.parse("{}")
        responseData["success"] = false
        responseData["code"] = 0

        file_size_in_bytes = File.size(aab_path.to_s)
        sha256 = Digest::SHA256.file(aab_path).hexdigest

        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/upload-url/for-obs?appId=#{app_id}&fileName=release.aab&contentLength=#{file_size_in_bytes}&suffix=aab")
        upload_filename = "release.aab"

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        request["client_id"] = client_id
        request["Authorization"] = "Bearer #{token}"
        request["Content-Type"] = "application/json"

        response = http.request(request)

        if !response.kind_of? Net::HTTPSuccess
          UI.user_error!("Cannot obtain upload url, please check API Token / Permissions (status code: #{response.code})")
          responseData["success"] = false
          return responseData
        end

        result_json = JSON.parse(response.body)

        if result_json.nil? || result_json['urlInfo'].nil? || result_json['urlInfo']['url'].nil?
          UI.message('Cannot obtain upload url')
          UI.user_error!(response.body)

          responseData["success"] = false
          return responseData
        else
          UI.important('Uploading app')
          # Upload App
          boundary = "755754302457647"
          uri = URI(result_json['urlInfo']['url'])
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Put.new(uri)
          request["Authorization"] = result_json['urlInfo']['headers']['Authorization']
          request["Content-Type"] = result_json['urlInfo']['headers']['Content-Type']
          request["user-agent"] = result_json['urlInfo']['headers']['user-agent']
          request["Host"] = result_json['urlInfo']['headers']['Host']
          request["x-amz-date"] = result_json['urlInfo']['headers']['x-amz-date']
          request["x-amz-content-sha256"] = result_json['urlInfo']['headers']['x-amz-content-sha256']

          request.body = File.read(aab_path.to_s)
          request.content_type = 'application/octet-stream'

          result = http.request(request)
          if !result.kind_of? Net::HTTPSuccess
            UI.user_error!(result.body)
            UI.user_error!("Cannot upload app, please check API Token / Permissions (status code: #{result.code})")
            responseData["success"] = false
            return responseData
          end

          if result.code.to_i == 200
            UI.success('Upload app to AppGallery Connect successful')
            UI.important("Saving app information")

            uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/app-file-info?appId=#{app_id}")

            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request = Net::HTTP::Put.new(uri.request_uri)
            request["client_id"] = client_id
            request["Authorization"] = "Bearer #{token}"
            request["Content-Type"] = "application/json"

            data = {fileType: 5, files: [{

                fileName: upload_filename,
                fileDestUrl: result_json['urlInfo']['objectId']

            }] }.to_json

            request.body = data
            response = http.request(request)
            if !response.kind_of? Net::HTTPSuccess
              UI.user_error!("Cannot save app info, please check API Token / Permissions (status code: #{response.code})")
              responseData["success"] = false
              return responseData
            end
            result_json = JSON.parse(response.body)

            if result_json['ret']['code'] == 0
              UI.success("App information saved.")
              responseData["success"] = true
              responseData["pkgVersion"] = result_json["pkgVersion"][0]
              return responseData
            else
              UI.user_error!(result_json)
              UI.user_error!("Failed to save app information")
              responseData["success"] = false
              return responseData
            end
          else
            responseData["success"] = false
            return responseData
          end
        end
      end

      def self.query_aab_compilation_status(token, client_id, app_id, pkgVersion)
        UI.important("Checking aab compilation status")
        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/aab/complile/status?appId=#{app_id}&pkgIds=#{pkgVersion}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        request["client_id"] = client_id
        request["Authorization"] = "Bearer #{token}"

        response = http.request(request)

        if !response.kind_of? Net::HTTPSuccess
          UI.user_error!("Cannot query compilation status (status code: #{response.code}, body: #{response.body})")
          return false
        end

        result_json = JSON.parse(response.body)

        if result_json['ret']['code'] == 0
          return result_json['pkgStateList'][0]['aabCompileStatus']
        else
          UI.user_error!(result_json)
          return -999
        end
      end

      def self.submit_app_for_review(token, client_id, app_id, message_for_moderator_path, release_notes_path, release_percent)
        UI.important("Submitting app for review")

        release_type = '&releaseType=3'
        changelog = ''

        if message_for_moderator_path != nil
          changelog_data = File.read(message_for_moderator_path)

          if changelog_data.length < 3 || changelog_data.length > 500
            UI.user_error!("Failed to submit app for review. Changelog file length is invalid")
            return
          else
            changelog = "&remark=" + CGI.escape(changelog_data)
          end
        end

        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/app-submit?appId=#{app_id}" + changelog + release_type)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request["client_id"] = client_id
        request["Authorization"] = "Bearer #{token}"
        request["Content-Type"] = "application/json"

        time_format = "%Y-%m-%dT%H:%M:%S%z"
        current_time = Time.now
        start_time = current_time + (1 * 60 * 60) # 1 час в секундах
        end_time = current_time + (7 * 24 * 60 * 60) # 7 дней в секундах
        start_time_str = start_time.strftime(time_format)
        end_time_str = end_time.strftime(time_format)

        request.body = {
            phasedReleaseStartTime: start_time_str,
            phasedReleaseEndTime: end_time_str,
            phasedReleasePercent: release_percent,
            phasedReleaseDescription: File.read(release_notes_path)
        }.to_json

        UI.important("Request URL: #{uri.to_s}")
        UI.important("Request Body: #{request.body}")

        response = http.request(request)

        if !response.kind_of? Net::HTTPSuccess
          UI.user_error!("Cannot submit app for review (status code: #{response.code}, body: #{response.body})")
          return false
        end

        result_json = JSON.parse(response.body)

        if result_json['ret']['code'] == 0
          UI.success("Successfully submitted app for review")
        elsif result_json['ret']['code'] == 204144660 && result_json['ret']['msg'].include?("It may take 2-5 minutes")
          UI.important(result_json)
          UI.important("Build is currently processing, waiting for 2 minutes before submitting again...")
          sleep(120)
          self.submit_app_for_review(token, client_id, app_id, message_for_moderator_path, release_notes_path, release_percent)
        else
          UI.user_error!(result_json)
          UI.user_error!("Failed to submit app for review.")
        end
      end

      def self.update_release_notes(token, client_id, app_id, release_notes_path)
        UI.important("Uploading app localization information from path: #{release_notes_path}")

        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/app-language-info?appId=#{app_id}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Put.new(uri.request_uri)
        request['client_id'] = client_id
        request['Authorization'] = "Bearer #{token}"
        request['Content-Type'] = 'application/json'
        body = { "lang": "ru-RU" }
        body[:newFeatures] = File.read(release_notes_path)

        UI.important(body.to_json)
        request.body = body.to_json
        response = http.request(request)

        UI.important(response)

        unless response.is_a? Net::HTTPSuccess
          UI.user_error!("Cannot upload localization info (status code: #{response.code}, body: #{response.body})")
          return false
        end

        result_json = JSON.parse(response.body)

        if result_json['ret']['code'].zero?
          UI.success("Successfully uploaded app localization info for #{release_notes_path}")
        else
          UI.user_error!(result_json)
        end
      end

    end
  end
end
