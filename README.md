# store_connect plugin

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-store_connect`, add it to your project by running:

```bash
fastlane add_plugin store_connect, git: "https://github.com/BMariya/fastlane-plugin-store_connect", branch: 'main'
```

## About store_connect

Allows send application for moderation to Rustore, Appgallery and Galaxy

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

```ruby
rustore_connect(
  key_id_path: ENV["RUSTORE_KEY_ID_PATH"], # path to Rustore key id
  private_key_path: ENV["RUSTORE_PRIVATE_KEY_PATH"], # path to Rustore private key
  package_name: ENV["RUSTORE_PACKAGE_NAME"], # package name of the app
  aab_google_path: ENV["RUSTORE_AAB_GOOGLE_PATH"], # path to aab with google services
  apk_hms_path: ENV["RUSTORE_APK_HMS_PATH"], # path to apk with hms services
  release_notes_path: ENV["RUSTORE_RELEASE_NOTES_PATH"], # path to release notes
  release_percent: ENV["RUSTORE_RELEASE_PERCENT"] # percent for publication
)

appgallery_connect(
  client_id_path: ENV["APPGALLERY_CLIENT_ID_PATH"], # path to Huawei AppGallery Connect client id
  client_secret_path: ENV["APPGALLERY_CLIENT_SECRET_PATH"], # path to Huawei AppGallery Connect client secret
  app_id: ENV["APPGALLERY_APP_ID"], # Huawei AppGallery Connect app id
  aab_hms_path: ENV["APPGALLERY_AAB_PATH"], # path to aab with hms services
  message_for_moderator_path: ENV["APPGALLERY_MESSAGE_FOR_MODERATOR_PATH"], # path to moderator message
  release_notes_path: ENV["APPGALLERY_RELEASE_NOTES_PATH"], # path to release notes
  release_percent: ENV["APPGALLERY_RELEASE_PERCENT"] # percent for publication
)

galaxy_connect(
  content_id: ENV["GALAXY_CONTENT_ID"], # Galaxy Content Id
  account_id_path: ENV["GALAXY_ACCOUNT_ID_PATH"], # path to Galaxy account id
  private_key_path: ENV["GALAXY_PRIVATE_KEY_PATH"], # path to Galaxy private key
  aab_google_path: ENV["GALAXY_AAB_GOOGLE_PATH"], # path to aab with google services
  ru_release_notes_path: ENV["GALAXY_RU_RELEASE_NOTES_PATH"], # path to ru release notes
  en_release_notes_path: ENV["GALAXY_EN_RELEASE_NOTES_PATH"], # path to en release notes
  ru_app_title_path: ENV["GALAXY_RU_APP_TITLE_PATH"], # path to ru app title
  ru_description_path: ENV["GALAXY_RU_DESCRIPTION_PATH"] # path to ru description
)
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
