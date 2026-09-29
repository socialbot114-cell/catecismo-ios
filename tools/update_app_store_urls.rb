require "json"
require "spaceship"

bundle_id = "br.com.CATECISMO.DAIGREJACAToLICA"
locale = "pt-BR"
metadata = "store-kit/metadata/#{locale}"
privacy_url = File.read("#{metadata}/privacy_url.txt").strip
support_url = File.read("#{metadata}/support_url.txt").strip
api_key = JSON.parse(File.read(ARGV.fetch(0)))

Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.from(hash: api_key)
app = Spaceship::ConnectAPI::App.find(bundle_id)
abort "App Store Connect app not found: #{bundle_id}" unless app

app_info = app.fetch_live_app_info
abort "Live App Store information not found" unless app_info
info_localization = app_info.get_app_info_localizations.find { |item| item.locale == locale }
abort "Live App Store localization not found: #{locale}" unless info_localization

if info_localization.privacy_policy_url != privacy_url
  info_localization.update(attributes: { privacy_policy_url: privacy_url })
  puts "Updated privacy policy URL for #{locale}"
else
  puts "Privacy policy URL already current for #{locale}"
end

platform = Spaceship::ConnectAPI::Platform.map("ios")
version = app.get_live_app_store_version(platform: platform)
abort "Live iOS App Store version not found" unless version
version_localization = version.get_app_store_version_localizations.find { |item| item.locale == locale }
abort "Live iOS App Store localization not found: #{locale}" unless version_localization

if version_localization.support_url != support_url
  version_localization.update(attributes: { support_url: support_url })
  puts "Updated support URL for #{locale}"
else
  puts "Support URL already current for #{locale}"
end
