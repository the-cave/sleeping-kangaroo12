# frozen_string_literal: true

require_relative 'lib/sleeping_kangaroo12/version'

::Gem::Specification.new do |spec|
  spec.name = 'sleeping_kangaroo12'
  spec.version = SleepingKangaroo12::VERSION
  spec.license = 'BSD-3-Clause'
  spec.author = 'Sarun Rattanasiri'
  spec.email = 'midnight_w@gmx.tw'

  spec.summary = 'KangarooTwelve, the hash algorithm, native binding for Ruby'
  spec.description = "KangarooTwelve binding for Ruby\n"\
    "The gem build on top of the official library, K12, maintained by the Keccak team themselves.\n"\
    'The implementation is highly optimized and supporting AVX512, AVX2, SSSE3 instruction sets.'
  spec.homepage = 'https://github.com/the-cave/sleeping-kangaroo12'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/tree/v#{spec.version}"
  spec.metadata['documentation_uri'] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"

  spec.files = [
    *::Dir['lib/**/*'],
    *::Dir['ext/binding/**/*'],
    *::Dir['ext/k12/**/*'].reject do |path|
      path.start_with?('ext/k12/bin') ||
        path.start_with?('ext/k12/tests') ||
        path.start_with?('ext/k12/.git') ||
        path.start_with?('ext/k12/.travis')
    end,
    'ext/Rakefile',
    'README.md',
    'LICENSE.md',
  ]
  spec.extensions << 'ext/Rakefile'
  spec.require_paths = ['lib']

  spec.add_dependency 'ffi', '~> 1.15.0'
  spec.add_dependency 'posix-spawn', '~> 0.3.0'
  spec.add_dependency 'rake', '~> 13.0.0'
end
