# SleepingKangaroo12

## What is it?

SleepingKangaroo12 is a Ruby binding of [KangarooTwelve](https://keccak.team/kangarootwelve.html), a fast cryptographic
hash function by the team behind SHA-3.

## Why not SHA-3?

SHA-3 is relatively slow without special function hardware, partly due to [NIST](https://www.nist.gov/), the organizer
of the SHA-3 competition, requested for a huge security margin from the candidates.

[The team behind Keccak](https://keccak.team/), the winner of the SHA-3 competition, feels that SHA-3 is not at the
sweet spot between trade-offs; they release a more performant, one-size-fit-all hash algorithm building on top of SHA-3
primitives, the KangarooTwelve.

Instead of making the function tunable like Keccak, they opinionatedly select the parameter for KangarooTwelve, so there
is one and only one KangarooTwelve variant.

## Why Sleeping?

Other Ruby bindings existed before mine; I added the adjective to distinguish mine. Furthermore, I wrote this binding in
pajamas, and I don't expect that I'll have the need to update this gem. From your perspective, it might look as if the
gem is sleeping. :-D

## What are specials?

Many!  
Just take a peek at the code, you'll notice that:

- It builds on top of the [eXtended Keccak Code Package (XKCP)](https://github.com/XKCP/XKCP), an easy-to-use and highly
  optimized library maintained by the Keccak team themselves.
- The binding auto-select and detects CPU features on installation, it supports `AVX512`, `AVX2`, and `SSSE3`
  instruction sets out of the box. And able to run on a machine without special instruction sets.
- Thin and stable binding; designed by a proper software architect
- Not limited to [Matz's Ruby Interpreter (MRI)](https://en.wikipedia.org/wiki/Ruby_MRI), this is due to the gem opting
  for [Ruby-FFI](https://github.com/ffi/ffi) instead of native extensions.
  (I only tested on MRI, though.)
- Compared to other hash functions, this binding actually shipped with the optimized implementation. Some
  other hash function might looks more performant on benchmarks, this may or may not translated to real-world
  performance.

## Prerequisites

In order to install the gem, your machine should be ready to build the XKCP package. Which mean you should prepare:

- GCC, the GNU Compiler Collection; our favorite
- GNU make
- xsltproc executable, normally comes with libxslt package
- And for the sake of completeness: Ruby, Bundler, and Ruby related stuffs

## Installation

Add this line to your application's Gemfile:

~~~ruby
gem 'sleeping_kangaroo12'
~~~

And then execute:

    $ bundle install

## Related to containers

OK, now, we have another issue since we detect CPU features on installation.

What if we want to build the container image, says Docker image, locally but deploy on a server.  
Chances are our workstation is using more recent CPU than the server.

I would recommend recompilation on container starts, simply do:
~~~
bundle exec gem pristine sleeping_kangaroo12
~~~
before the command, you actually want to run.  
This will trigger the recompilation of SleepingKangaroo12.

## Usage Examples

Test vectors stolen
from [konsolebox/digest-kangarootwelve-ruby](https://github.com/konsolebox/digest-kangarootwelve-ruby), another Ruby
binding.

~~~ruby
# Shortcuts
#
::SleepingKangaroo12::Digest.digest('abc')
# Output: "\xAB\x17O2\x8CU\xA5Q\v\v \x97\x91\xBF\x8B`\xE8\x01\xA7\xCF\xC2\xAAB\x04-\xCB\x8FT\x7F\xBE:}"
#
::SleepingKangaroo12::Digest.hexdigest('abc')
# Output: "ab174f328c55a5510b0b209791bf8b60e801a7cfc2aa42042dcb8f547fbe3a7d"

# Multiple updates
#
digest = ::SleepingKangaroo12::Digest.new
digest.update('a')
digest.update('b')
digest.update('c')
digest.hexdigest
# Output: "ab174f328c55a5510b0b209791bf8b60e801a7cfc2aa42042dcb8f547fbe3a7d"

# Hashing with a key, similar to HMAC
# KangarooTwelve call the key "customization", it is the same thing, FYI
#
digest = ::SleepingKangaroo12::Digest.new(key: 'secret')
digest << 'abc' # alternate form of update method
digest.hexdigest
# Output: "dc1fd53f85402e2b34fa92bd87593dd9c3fe6cc49d9db6c05dc0cf26c6a7e03f"
# HMAC requires 2 parses of hashing, the customization is definitely faster

# You can control the output length too
#
digest = ::SleepingKangaroo12::Digest.new(key: 'secret', output_length: 5)
digest << 'abc'
digest.hexdigest
# Output: "dc1fd53f85"
# This is marginally faster than truncating the output yourself.
#
digest = ::SleepingKangaroo12::Digest.new(key: 'secret', output_length: 64)
digest << 'abc'
digest.hexdigest
# Output: "dc1fd53f85402e2b34fa92bd87593dd9c3fe6cc49d9db6c05dc0cf26c6a7e03fc4b18c621b57dbb8967094b160dbf22ee42402d7e3d45ecab4b02ef0db14b105"
# The output is longer now, but the security claim is still the same.
# (as 256-bit output length, which translated to the security level of 128-bit)

# Weird parameters
#
digest = ::SleepingKangaroo12::Digest.new(key: 'secret', output_length: 1_000_000_000_000)
# This will error; I arbitrary set the limit at 1MiB - 1 bytes as a safety measure. Same for length <= 0
# If you have a use case for something out of range, feel free to discuss.
# You are probably looking for a stream cipher instead of a hash function, though.

# The options work with shortcuts too
# 
::SleepingKangaroo12::Digest.hexdigest('abc', key: 'secret')
# Output: "dc1fd53f85402e2b34fa92bd87593dd9c3fe6cc49d9db6c05dc0cf26c6a7e03f"
~~~

## About CPU Throttling

At the time of this writing, if you use a lot of AVX-512, your CPU would heat up significantly; this leads to frequency throttling.

If you plan to use KangarooTwelve heavily yet still have other functionalities impacted by lower CPU frequencies
(like [Cloudflare](https://blog.cloudflare.com/on-the-dangers-of-intels-frequency-scaling/)),
you may want to customize the build to prevent the throttling.

If that is the case, please check [konsolebox/digest-kangarootwelve-ruby](https://github.com/konsolebox/digest-kangarootwelve-ruby).
At the time of this writing, they offer customizable build; in contrast, SleepingKangaroo12 will focus on ease of use.

## License

SleepingKangaroo12 is released under the [BSD 3-Clause License](LICENSE.md). :tada:
