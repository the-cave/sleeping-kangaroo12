# frozen_string_literal: true

require_relative 'lib/sleeping_kangaroo12/version'

::Gem::Specification.new do |spec|
  spec.name = 'sleeping_kangaroo12'
  spec.version = SleepingKangaroo12::VERSION
  spec.author = 'Sarun Rattanasiri'
  spec.email = 'midnight_w@gmx.tw'
  spec.license = 'BSD-3-Clause'

  spec.summary = 'A binding of the KangarooTwelve hash algorithm for Ruby'
  spec.description = 'This gem brought the hash algorithm, KangarooTwelve, to Ruby. '\
    'It uses the official library, K12, maintained by the Keccak team themselves. '\
    'The implementation is highly optimized on popular hardware, including AVX512, AVX2, SSSE3 instruction sets.'
  spec.homepage = 'https://github.com/the-cave/sleeping-kangaroo12'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "https://github.com/the-cave/sleeping-kangaroo12/tree/v#{spec.version}"

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

  spec.add_dependency 'ffi', '~> 1.15.5'
  spec.add_dependency 'posix-spawn', '~> 0.3.15'
  spec.add_dependency 'rake', '~> 13.0.6'
end
