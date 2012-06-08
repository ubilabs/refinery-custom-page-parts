Gem::Specification.new do |s|
  s.platform          = Gem::Platform::RUBY
  s.name              = 'refinerycms-custom_page_parts'
  s.version           = '1.0'
  s.description       = 'Ruby on Rails Custom Page Parts engine for Refinery CMS'
  s.date              = '2011-09-08'
  s.summary           = 'Custom Page Parts engine for Refinery CMS'
  s.require_paths     = %w(lib)
  s.files             = Dir['lib/**/*', 'config/**/*', 'app/**/*']
end
