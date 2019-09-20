# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

def extension_pods
    pod 'DateToolsSwift'
    pod 'SwiftyJSON'
    pod 'KeychainAccess'
end

target 'budJet' do
  use_frameworks!

  pod 'SnapKit'
  pod 'IQKeyboardManagerSwift'
  pod 'Charts'
  pod 'SwipeCellKit'
  pod 'BetterSegmentedControl'
  pod 'JTAppleCalendar'
  pod 'SkyFloatingLabelTextField'
  pod 'SmileLock'
  
  extension_pods
end

target :'budjetwidget' do
    use_frameworks!
    extension_pods
end
