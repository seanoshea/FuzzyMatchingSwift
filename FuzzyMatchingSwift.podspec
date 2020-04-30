Pod::Spec.new do |s|
  s.name                      = 'FuzzyMatchingSwift'
  s.version                   = '0.8.1'
  s.summary                   = 'Fuzzy matching String extensions.'
  s.description               = <<-DESC
FuzzyMatchingSwift provides String extensions which allow developers to find similar Strings in Strings and Arrays of Strings.
                       DESC
  s.homepage                  = 'https://github.com/seanoshea/FuzzyMatchingSwift'
  s.license                   = { :type => 'Apache 2', :file => 'LICENSE' }
  s.author                    = { 'seanoshea' => 'oshea.ie@gmail.com' }
  s.source                    = { :git => 'https://github.com/seanoshea/FuzzyMatchingSwift.git', :tag => s.version.to_s }
  s.social_media_url          = 'https://twitter.com/seanoshea'
  s.requires_arc              = true
  s.compiler_flags            = '-whole-module-optimization'
  s.ios.deployment_target     = '13.2'
  s.osx.deployment_target     = '10.15'
  s.watchos.deployment_target = '6.1'
  s.tvos.deployment_target    = '13.2'
  s.source_files              = 'FuzzyMatchingSwift/Classes/**/*'
  s.swift_version             = '5.0'
end
