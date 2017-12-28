Pod::Spec.new do |s|
  s.name         = "leveldb-iOS"
  s.version      = "1.20"
  s.summary      = "LevelDB is a fast key-value storage library written at Google that provides an ordered mapping from string keys to string values."
  s.description  = <<-DESC
    LevelDB is a fast key-value storage library written at Google that provides an ordered mapping from string keys to string values.
                   DESC
  s.homepage     = "https://github.com/google/leveldb"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "calvingit" => "calvin_cheung@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/calvingit/leveldb-iOS.git", :tag => "#{s.version}" }
  s.source_files  = "leveldb/include/**/*.{h}", "*.{h,m,mm}"
  s.public_header_files = "leveldb/include/leveldb/*.h"
  s.library   = "c++"
  s.requires_arc = true
  s.vendored_libraries = 'leveldb/libleveldb.a', 'leveldb/libmemenv.a'
  s.xcconfig = { "HEADER_SEARCH_PATHS" => "${PODS_ROOT}/leveldb-iOS/include/leveldb" }
end