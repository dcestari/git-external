Gem::Specification.new do |s|
  s.name        = 'git-external'
  s.version     = '0.2.0'
  s.date        = '2012-10-28'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Daniel Cestari"]
  s.email       = ["dcestari@gmail.com"]
  s.homepage    = "http://github.com/dcestari/git-external"
  s.summary     = "Git version of an svn:external, an alternative to Git Submodule"
  s.description = "Extension for git which adds a command providing similar functionality to git submodules but without attaching each module to a single version"

  s.executables = ['git-external']
  s.files       = ['lib/git_external.rb']
end

