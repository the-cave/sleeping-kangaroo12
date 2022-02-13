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
    'It uses the official library, XKCP, by the team members behind the original paper. '\
    'The implementation is highly optimized on popular hardware, including AVX512, AVX2, SSSE3 instruction sets.'
  spec.homepage = 'https://slime.systems/'
  spec.required_ruby_version = '>= 2.6.0'

  # spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "https://github.com/the-cave/sleeping-kangaroo12/tree/v#{SleepingKangaroo12::VERSION}"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = [
    *::Dir['lib/**/*'],
    *::Dir['ext/binding/**/*'],
    *::Dir['ext/config/**/*'],
    *::Dir['ext/xkcp/**/*'].reject do |path|
      path.start_with?('ext/xkcp/bin') ||
        path.start_with?('ext/xkcp/doc') ||
        path.start_with?('ext/xkcp/Standalone') ||
        path.start_with?('ext/xkcp/tests')
    end,
    'ext/Rakefile',
    'README.md',
  ]
  spec.extensions << 'ext/Rakefile'
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'ffi', '~> 1.15.5'
  spec.add_dependency 'posix-spawn', '~> 0.3.15'
  spec.add_dependency 'rake', '~> 13.0.6'
end
