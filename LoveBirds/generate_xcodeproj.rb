#!/usr/bin/env ruby
# Generates LoveBirds.xcodeproj from project.yml structure.
# Mirrors the XcodeGen config so swapping to XcodeGen later is seamless.

require 'xcodeproj'
require 'pathname'

ROOT = Pathname.new(__dir__).expand_path
PROJECT_PATH = ROOT.join('LoveBirds.xcodeproj').to_s

# Remove existing project so this is idempotent
require 'fileutils'
FileUtils.rm_rf(PROJECT_PATH)

project = Xcodeproj::Project.new(PROJECT_PATH)
project.root_object.attributes['LastUpgradeCheck'] = '1540'
project.root_object.attributes['LastSwiftUpdateCheck'] = '1540'

# ---------- Base settings shared by every config ----------
SHARED_BASE = {
  'SWIFT_VERSION' => '5.9',
  'CURRENT_PROJECT_VERSION' => '1',
  'MARKETING_VERSION' => '1.0',
  'CODE_SIGN_STYLE' => 'Automatic',
  'DEVELOPMENT_TEAM' => '',
  'ENABLE_USER_SCRIPT_SANDBOXING' => 'YES',
  'CLANG_ENABLE_MODULES' => 'YES',
  'SWIFT_EMIT_LOC_STRINGS' => 'YES',
  'ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES' => 'NO',
}.freeze

# ---------- Helpers ----------
def add_source_dir(project, group, dir, target)
  Pathname.glob(dir.join('**', '*.swift')).each do |file|
    relative = file.relative_path_from(ROOT).to_s
    group_path = file.dirname.relative_path_from(dir).to_s
    container = if group_path == '.'
                  group
                else
                  group_path.split(File::SEPARATOR).reduce(group) do |g, name|
                    g.find_subpath(name, true).tap { |sub| sub.set_source_tree('<group>') }
                  end
                end
    ref = container.new_reference(relative)
    ref.set_source_tree('SOURCE_ROOT')
    target.add_file_references([ref])
  end
end

def add_resources(project, group, files, target)
  files.each do |path|
    next unless path.exist?
    relative = path.relative_path_from(ROOT).to_s
    ref = group.new_reference(relative)
    ref.set_source_tree('SOURCE_ROOT')
    if path.extname == '.xcassets' || path.basename.to_s.end_with?('.storekit') || path.directory?
      target.add_resources([ref])
    else
      target.add_resources([ref])
    end
  end
end

def add_plist_file_ref(project, group, path)
  relative = path.relative_path_from(ROOT).to_s
  ref = group.new_reference(relative)
  ref.set_source_tree('SOURCE_ROOT')
  ref
end

def apply_settings(target, settings)
  target.build_configurations.each do |config|
    settings.each { |k, v| config.build_settings[k] = v }
  end
end

# ---------- Local Swift Package: LoveBirdsKit ----------
package_ref = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
package_ref.relative_path = 'Packages/LoveBirdsKit'
project.root_object.package_references << package_ref

def package_product(project, package_ref, product_name)
  product = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
  product.package = package_ref
  product.product_name = product_name
  product
end

# ---------- Target: LoveBirds (iOS app) ----------
ios_target = project.new_target(:application, 'LoveBirds', :ios, '17.0')
ios_group = project.main_group.find_subpath('LoveBirds', true)
ios_group.set_source_tree('<group>')

add_source_dir(project, ios_group, ROOT.join('Sources/iOS'), ios_target)

ios_resources_group = ios_group.find_subpath('Resources', true)
ios_resources_group.set_source_tree('<group>')
add_resources(project, ios_resources_group,
              [ROOT.join('Sources/iOS/Resources/Assets.xcassets'),
               ROOT.join('Resources/Products.storekit')],
              ios_target)

ios_plist_ref = add_plist_file_ref(project, ios_resources_group, ROOT.join('Sources/iOS/Resources/Info.plist'))
ios_entitlements_ref = add_plist_file_ref(project, ios_resources_group, ROOT.join('Sources/iOS/Resources/LoveBirds.entitlements'))

apply_settings(ios_target, SHARED_BASE.merge(
  'PRODUCT_BUNDLE_IDENTIFIER' => 'com.lokei.lovebirds',
  'PRODUCT_NAME' => 'LoveBirds',
  'INFOPLIST_FILE' => ios_plist_ref.real_path.relative_path_from(ROOT).to_s,
  'CODE_SIGN_ENTITLEMENTS' => ios_entitlements_ref.real_path.relative_path_from(ROOT).to_s,
  'IPHONEOS_DEPLOYMENT_TARGET' => '17.0',
  'TARGETED_DEVICE_FAMILY' => '1,2',
  'ASSETCATALOG_COMPILER_APPICON_NAME' => 'AppIcon',
  'ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME' => 'AccentColor',
  'SUPPORTS_MACCATALYST' => 'NO',
  'SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD' => 'NO',
  'INFOPLIST_KEY_NSHumanReadableCopyright' => '© 2026 Lokei',
  'INFOPLIST_KEY_UIApplicationSceneManifest_Generation' => 'YES',
  'INFOPLIST_KEY_UILaunchScreen_Generation' => 'YES'
))

ios_target.package_product_dependencies << package_product(project, package_ref, 'LoveBirdsKit')

# ---------- Target: LoveBirdsWatch (watchOS app) ----------
watch_target = project.new_target(:application, 'LoveBirdsWatch', :watchos, '10.0')
watch_group = project.main_group.find_subpath('LoveBirdsWatch', true)
watch_group.set_source_tree('<group>')

add_source_dir(project, watch_group, ROOT.join('Sources/Watch'), watch_target)

watch_resources_group = watch_group.find_subpath('Resources', true)
watch_resources_group.set_source_tree('<group>')
add_resources(project, watch_resources_group,
              [ROOT.join('Sources/Watch/Resources/Assets.xcassets')],
              watch_target)

watch_plist_ref = add_plist_file_ref(project, watch_resources_group, ROOT.join('Sources/Watch/Resources/Info.plist'))
watch_entitlements_ref = add_plist_file_ref(project, watch_resources_group, ROOT.join('Sources/Watch/Resources/LoveBirdsWatch.entitlements'))

apply_settings(watch_target, SHARED_BASE.merge(
  'PRODUCT_BUNDLE_IDENTIFIER' => 'com.lokei.lovebirds.watchkitapp',
  'PRODUCT_NAME' => 'LoveBirdsWatch',
  'INFOPLIST_FILE' => watch_plist_ref.real_path.relative_path_from(ROOT).to_s,
  'CODE_SIGN_ENTITLEMENTS' => watch_entitlements_ref.real_path.relative_path_from(ROOT).to_s,
  'WATCHOS_DEPLOYMENT_TARGET' => '10.0',
  'TARGETED_DEVICE_FAMILY' => '4',
  'SDKROOT' => 'watchos',
  'SUPPORTED_PLATFORMS' => 'watchos watchsimulator',
  'ASSETCATALOG_COMPILER_APPICON_NAME' => 'AppIcon',
  'WATCHOS_COMPANION_APP_BUNDLE_IDENTIFIER' => 'com.lokei.lovebirds',
  'INFOPLIST_KEY_WKApplication' => 'YES',
  'INFOPLIST_KEY_WKAppCategory' => 'social-networking',
  'INFOPLIST_KEY_WKCompanionAppBundleIdentifier' => 'com.lokei.lovebirds'
))

watch_target.package_product_dependencies << package_product(project, package_ref, 'LoveBirdsKit')

# ---------- Target: LoveBirdsWidget (iOS WidgetKit extension) ----------
widget_target = project.new_target(:app_extension, 'LoveBirdsWidget', :ios, '17.0')
widget_group = project.main_group.find_subpath('LoveBirdsWidget', true)
widget_group.set_source_tree('<group>')

add_source_dir(project, widget_group, ROOT.join('Sources/Widget'), widget_target)

widget_resources_group = widget_group.find_subpath('Resources', true)
widget_resources_group.set_source_tree('<group>')
add_resources(project, widget_resources_group,
              [ROOT.join('Sources/Widget/Resources/Assets.xcassets')],
              widget_target)

widget_plist_ref = add_plist_file_ref(project, widget_resources_group, ROOT.join('Sources/Widget/Resources/Info.plist'))
widget_entitlements_ref = add_plist_file_ref(project, widget_resources_group, ROOT.join('Sources/Widget/Resources/LoveBirdsWidget.entitlements'))

apply_settings(widget_target, SHARED_BASE.merge(
  'PRODUCT_BUNDLE_IDENTIFIER' => 'com.lokei.lovebirds.widget',
  'PRODUCT_NAME' => 'LoveBirdsWidget',
  'INFOPLIST_FILE' => widget_plist_ref.real_path.relative_path_from(ROOT).to_s,
  'CODE_SIGN_ENTITLEMENTS' => widget_entitlements_ref.real_path.relative_path_from(ROOT).to_s,
  'IPHONEOS_DEPLOYMENT_TARGET' => '17.0',
  'TARGETED_DEVICE_FAMILY' => '1,2',
  'SKIP_INSTALL' => 'YES',
  'CODE_SIGN_STYLE' => 'Automatic'
))

widget_target.package_product_dependencies << package_product(project, package_ref, 'LoveBirdsKit')

# ---------- Target: LoveBirdsMessages (iMessage extension) ----------
messages_target = project.new_target(:app_extension, 'LoveBirdsMessages', :ios, '17.0')
messages_group = project.main_group.find_subpath('LoveBirdsMessages', true)
messages_group.set_source_tree('<group>')

add_source_dir(project, messages_group, ROOT.join('Sources/iMessage'), messages_target)

messages_resources_group = messages_group.find_subpath('Resources', true)
messages_resources_group.set_source_tree('<group>')
add_resources(project, messages_resources_group,
              [ROOT.join('Sources/iMessage/Resources/Assets.xcassets')],
              messages_target)

messages_plist_ref = add_plist_file_ref(project, messages_resources_group, ROOT.join('Sources/iMessage/Resources/Info.plist'))
messages_entitlements_ref = add_plist_file_ref(project, messages_resources_group, ROOT.join('Sources/iMessage/Resources/LoveBirdsMessages.entitlements'))

apply_settings(messages_target, SHARED_BASE.merge(
  'PRODUCT_BUNDLE_IDENTIFIER' => 'com.lokei.lovebirds.messages',
  'PRODUCT_NAME' => 'LoveBirdsMessages',
  'INFOPLIST_FILE' => messages_plist_ref.real_path.relative_path_from(ROOT).to_s,
  'CODE_SIGN_ENTITLEMENTS' => messages_entitlements_ref.real_path.relative_path_from(ROOT).to_s,
  'IPHONEOS_DEPLOYMENT_TARGET' => '17.0',
  'TARGETED_DEVICE_FAMILY' => '1,2',
  'SKIP_INSTALL' => 'YES'
))

messages_target.package_product_dependencies << package_product(project, package_ref, 'LoveBirdsKit')

# ---------- Embed extensions and watch app in iOS app ----------
def embed_target(host, embedded, destination_subfolder, name)
  phase = host.copy_files_build_phases.find { |p| p.name == name }
  phase ||= begin
    p = host.new_copy_files_build_phase(name)
    p.dst_subfolder_spec = destination_subfolder
    p
  end
  build_file = phase.add_file_reference(embedded.product_reference)
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
end

# Embed extensions (PlugIns dst = "13")
['LoveBirdsWidget', 'LoveBirdsMessages'].each do |name|
  ext = project.targets.find { |t| t.name == name }
  embed_target(ios_target, ext, '13', 'Embed Foundation Extensions')
  ios_target.add_dependency(ext)
end

# Embed watch app (Products dst = "16" with subpath = "$(CONTENTS_FOLDER_PATH)/Watch")
watch_phase = ios_target.copy_files_build_phases.find { |p| p.name == 'Embed Watch Content' }
watch_phase ||= begin
  p = ios_target.new_copy_files_build_phase('Embed Watch Content')
  p.dst_subfolder_spec = '16'
  p.dst_path = '$(CONTENTS_FOLDER_PATH)/Watch'
  p
end
watch_build_file = watch_phase.add_file_reference(watch_target.product_reference)
watch_build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
ios_target.add_dependency(watch_target)

# ---------- Shared schemes ----------
schemes_dir = Pathname.new(PROJECT_PATH).join('xcshareddata', 'xcschemes')
FileUtils.mkdir_p(schemes_dir)

%w[LoveBirds LoveBirdsWatch].each do |scheme_name|
  target = project.targets.find { |t| t.name == scheme_name }
  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(target)
  scheme.set_launch_target(target)
  scheme.save_as(PROJECT_PATH, scheme_name, true)
end

# ---------- Write project ----------
project.save

puts "Generated #{PROJECT_PATH}"
puts "Targets: #{project.targets.map(&:name).join(', ')}"
