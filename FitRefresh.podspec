Pod::Spec.new do |s|
  s.name        = "FitRefresh"
  s.version     = "1.1.0"
  s.summary     = "FitRefresh makes it easy to refresh in Swift3+"
  s.platform     = :ios, "8.0"
  s.homepage    = "https://github.com/CoderCYLee/FitRrefesh"
  s.license     = { :type => "MIT" }
  s.authors     = { "Cyrill" => "lichunyang@outlook.com" }

  s.requires_arc = true

  s.source   = { :git => "https://github.com/CoderCYLee/FitRrefesh.git", :tag => s.version }
  s.source_files = "Sources/*.swift"
  s.resource = "Sources/*.bundle"
  s.pod_target_xcconfig =  {
        'SWIFT_VERSION' => '3.0',
  }
end
