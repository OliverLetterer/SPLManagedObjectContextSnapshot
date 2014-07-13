Pod::Spec.new do |s|
  s.name             = "SPLManagedObjectContextSnapshot"
  s.version          = "1.0.0"
  s.summary          = "Change tracking for a NSManagedObjectContext."
  s.homepage         = "https://github.com/OliverLetterer/SPLManagedObjectContextSnapshot"
  s.license          = 'MIT'
  s.author           = { "Oliver Letterer" => "oliver.letterer@gmail.com" }
  s.source           = { :git => "https://github.com/OliverLetterer/SPLManagedObjectContextSnapshot.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/oletterer'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.frameworks = 'CoreData'
end
