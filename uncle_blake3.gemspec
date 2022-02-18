# frozen_string_literal: true

require_relative 'lib/uncle_blake3/version'

::Gem::Specification.new do |spec|
  spec.name = 'uncle_blake3'
  spec.version = ::UncleBlake3::VERSION
  spec.license = 'BSD-3-Clause'
  spec.author = 'Sarun Rattanasiri'
  spec.email = 'midnight_w@gmx.tw'

  spec.summary = 'Blake3, the hash algorithm, native binding for Ruby'
  spec.description = "Blake3 binding for Ruby\n"\
    "The gem build on top of the official Blake3 implementation maintained by the team behind Blake3 themselves.\n"\
    'It supports `AVX512`, `AVX2`, `SSE4.1`, and `SSE2` acceleration with thin and stable binding.'
  spec.homepage = 'https://github.com/the-cave/uncle-blake3'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/tree/v#{spec.version}"
  spec.metadata['documentation_uri'] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"

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

  spec.add_dependency 'ffi', '~> 1.15.0'
  spec.add_dependency 'rake', '~> 13.0.0'
end
