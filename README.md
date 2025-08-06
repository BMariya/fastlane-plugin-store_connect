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
)

galaxy_connect(
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
