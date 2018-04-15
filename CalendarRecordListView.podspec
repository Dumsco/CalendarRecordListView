Pod::Spec.new do |s|
  s.name         = "CalendarRecordListView"
  s.version      = "0.1.0"
  s.summary      = "Calendar and daily list view"
  s.homepage     = "https://github.com/Dumsco/CalendarRecordListView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Yuuya Ono" => "yuya.ono@dumsco.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/Dumsco/CalendarRecordListView.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/*.swift"
  s.requires_arc = true
  s.static_framework = true
  s.swift_version = "4.1"
end
