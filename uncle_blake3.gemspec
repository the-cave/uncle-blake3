# frozen_string_literal: true

require_relative 'lib/uncle_blake3/version'

::Gem::Specification.new do |spec|
  spec.name = 'uncle_blake3'
  spec.version = ::UncleBlake3::VERSION
  spec.author = 'Sarun Rattanasiri'
  spec.email = 'midnight_w@gmx.tw'

  spec.summary = 'A binding of the Blake3 hash algorithm for Ruby'
  spec.description = 'This gem brought the hash algorithm, Blake3, to Ruby. '\
    'It uses the official Blake3 implementation which optimized and maintained by the original Blake3 team themselves.'
  spec.homepage = 'https://github.com/the-cave/uncle-blake3'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "https://github.com/the-cave/uncle-blake3/tree/v#{spec.version}"

  spec.files = [
    *::Dir['lib/**/*'],
    *::Dir['ext/binding/**/*'],
    *::Dir['ext/blake3/c/**/*'].reject do |path|
      path.include?('/.git') || path.include?('/blake3_c_rust_bindings')
    end,
    'ext/Rakefile',
    'README.md',
    'LICENSE.md',
  ]
  spec.extensions << 'ext/Rakefile'
  spec.require_paths = ['lib']

  spec.add_dependency 'ffi', '~> 1.15.5'
  spec.add_dependency 'rake', '~> 13.0.6'
end
