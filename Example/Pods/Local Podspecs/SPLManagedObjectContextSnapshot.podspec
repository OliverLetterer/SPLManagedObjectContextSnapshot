#
# Be sure to run `pod lib lint SPLManagedObjectContextSnapshot.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SPLManagedObjectContextSnapshot"
  s.version          = "0.1.0"
  s.summary          = "Snapshots a NSManagedObjectContext and tracks its changes."
  s.homepage         = "https://github.com/OliverLetterer/SPLManagedObjectContextSnapshot"
  s.license          = 'MIT'
  s.author           = { "Oliver Letterer" => "oliver.letterer@gmail.com" }
  s.source           = { :git => "https://github.com/OliverLetterer/SPLManagedObjectContextSnapshot.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/olettere'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.frameworks = 'CoreData'
end
