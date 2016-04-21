#
#  Be sure to run `pod spec lint AwesomeTableAnimationCalculator.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "AwesomeTableAnimationCalculator"
  s.version      = "0.8"
  s.summary      = "This code helps to detect changed (add, move, delete, refresh) if cell and section indexes for animatable updating Collection/Table view"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.description  = <<-DESC
                            There are times when you need to determine what was changed in a table (collection) model
                            to update it with animations. It can be even more complex task when sections are involved.
                            Awesome Table Animation Calculator provides simple interface for this task. It holds
                            data model for the table and can calculate animatable difference for some changes (and
                            apply them to the UICollectionView/UITableView afterwards).
                   DESC

  s.homepage     = "https://github.com/bealex/AwesomeTableAnimationCalculator"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  s.author             = { "Alexander Babaev" => "alex@lonelybytes.com" }
  s.social_media_url   = "http://twitter.com/bealex"

  s.platform     = :ios, "8.0"
  # need to test with OS X, watchOS, tvOS


  s.source       = { :git => "https://github.com/bealex/AwesomeTableAnimationCalculator.git", :tag => "0.8" }
  s.source_files  = "Code/ATableAnimation/**/*.swift"
  s.exclude_files = "Code/Example", "Resources", "ATableAnimationCalculator.xcodeproj/**"

  s.module_name = 'AwesomeTableAnimationCalculator'

end
