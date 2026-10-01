require "json"
require "spaceship"

bundle_id = "br.com.CATECISMO.DAIGREJACAToLICA"
app_version = "1.2.2"
locale = "pt-BR"
metadata = "store-kit/metadata/#{locale}"
privacy_url = File.read("#{metadata}/privacy_url.txt").strip
support_url = File.read("#{metadata}/support_url.txt").strip
api_key = JSON.parse(File.read(ARGV.fetch(0)))

Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.from(hash: api_key)
app = Spaceship::ConnectAPI::App.find(bundle_id)
abort "App Store Connect app not found: #{bundle_id}" unless app

platform = Spaceship::ConnectAPI::Platform.map("ios")
app.ensure_version!(app_version, platform: platform)
app_info = app.fetch_edit_app_info
abort "Editable App Store information not found for version #{app_version}" unless app_info
info_localization = app_info.get_app_info_localizations.find { |item| item.locale == locale }
unless info_localization
  info_localization = app_info.create_app_info_localization(attributes: { locale: locale })
end

if info_localization.privacy_policy_url != privacy_url
  info_localization.update(attributes: { privacy_policy_url: privacy_url })
  puts "Updated privacy policy URL for #{locale}"
else
  puts "Privacy policy URL already current for #{locale}"
end

version = app.get_edit_app_store_version(platform: platform)
abort "Editable iOS App Store version #{app_version} not found" unless version && version.version_string == app_version
version_localization = version.get_app_store_version_localizations.find { |item| item.locale == locale }
unless version_localization
  version_localization = version.create_app_store_version_localization(attributes: { locale: locale })
end

if version_localization.support_url != support_url
  version_localization.update(attributes: { support_url: support_url })
  puts "Updated support URL for version #{app_version} (#{locale})"
else
  puts "Support URL already current for version #{app_version} (#{locale})"
end
