Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-mixi_community"
  gem.version       = "0.0.3"
  gem.authors       = ["todesking"]
  gem.email         = ["discommunicative@gmail.com"]
  gem.summary       = %q{Fluentd input plugin, source from Mixi community}
  gem.homepage      = "https://github.com/todesking/fluent-plugin-mixi_community"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "mixi-community", '>=0.0.4'
  gem.add_runtime_dependency "fluentd"
  gem.add_runtime_dependency "pit"
end
