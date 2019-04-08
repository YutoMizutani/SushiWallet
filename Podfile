# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'SushiWallet' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SushiWallet
  pod 'Alamofire'
  pod 'BitcoinKit'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxSwift'
  pod 'SVProgressHUD'

  target 'SushiWalletTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SushiWalletUITests' do
    inherit! :search_paths
    # Pods for testing
    pod 'BitcoinKit'
    pod 'RxDataSources'
    pod 'SVProgressHUD'
  end

end
