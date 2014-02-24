#
#  Be sure to run `pod spec lint LPMFetchedResultsDisplayManager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "LPMFetchedResultsDisplayManager"
  s.version      = "0.0.1"
  s.summary      = "Zero-boilerplate display of NSManagedObjects"
  s.description  = <<-DESC
                   LPMFetchedResultsDisplayManager offers 'zero-boilerplate display of NSManagedObjects'. What does that mean?

                   Typically, in order to display managed objects in a table view, you have to write TONS of boilerplate code.
                   This is mostly code that makes your view controller conform to the UITableViewDelegate, UITableViewDatasource, 
                   and NSFetchedResultsControllerDelegate protocols. And importantly, this code is  NEARLY IDENTICAL every time 
                   you write it. LPMFetchedResultsDisplayManager encapsulates this boilerplate, and exposes the only two properties 
                   you should be worrying about: the fetch request (aka a description of the managed objects you want to display) 
                   and the table view (where you want to display them). Then, when you're  ready to display, just call the 
                   LPMFetchedResultsDisplayManager's reloadData method, and it does the hard work.
                   DESC
  s.homepage     = "http://github.com/lonelyplanet/LPMFetchedResultsDisplayManager"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Matthew McCroskey" => "matthew.mccroskey@lonelyplanet.com" }
  s.platform     = :ios, '6.0'
  #s.source       = { :git => "http://EXAMPLE/LPMFetchedResultsDisplayManager.git", :tag => "0.0.1" }
  s.source_files  = 'LPMFetchedResultsDisplayManager/*'
  s.framework  = 'CoreData'
  s.requires_arc = true

end
