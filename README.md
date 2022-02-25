# SleepingKangaroo12

[![GitHub version](https://badge.fury.io/gh/the-cave%2Fsleeping-kangaroo12.svg)](https://badge.fury.io/gh/the-cave%2Fsleeping-kangaroo12)
[![Gem Version](https://badge.fury.io/rb/sleeping_kangaroo12.svg)](https://badge.fury.io/rb/sleeping_kangaroo12)

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

- It builds on top of the [K12](https://github.com/XKCP/K12), an easy-to-use and highly
  optimized library maintained by the Keccak team themselves.
- The instruction set `AVX512`, `AVX2`, and `SSSE3` will be detected at runtime to select the optimization dynamically.
- Thin and stable binding layer
- Not limited to [Matz's Ruby Interpreter (MRI)](https://en.wikipedia.org/wiki/Ruby_MRI), this is due to the gem opting
  for [Ruby-FFI](https://github.com/ffi/ffi) instead of using the API exposed by `ruby.h`.
  (I only tested on MRI, though.)

## Prerequisites

In order to install the gem, your machine should be ready to build the K12 package. Which mean you should prepare:

- GCC, the GNU Compiler Collection; our favorite
- GNU make
- xsltproc executable, normally comes with libxslt package
- Ruby related stuffs

### TL;DR for Ubuntu-liked OS

~~~bash
sudo apt install build-essential xsltproc
~~~

## Installation

Add this line to your application's Gemfile:

~~~ruby
gem 'sleeping_kangaroo12'
~~~

Check the [prerequisites](#prerequisites); and then execute:

    $ bundle install

## Usage Examples

Test vectors stolen
from [konsolebox/digest-kangarootwelve-ruby](https://github.com/konsolebox/digest-kangarootwelve-ruby), another Ruby
binding.

~~~ruby
# basic usage
::SleepingKangaroo12::Digest.hexdigest('abc')
# => "ab174f328c55a5510b0b209791bf8b60e801a7cfc2aa42042dcb8f547fbe3a7d"

# streaming
digest = ::SleepingKangaroo12::Digest.new
digest << 'a'
digest << 'b'
digest << 'c'
digest.hexdigest
# => "ab174f328c55a5510b0b209791bf8b60e801a7cfc2aa42042dcb8f547fbe3a7d"
# `<<` is an alias of `update`, use the one you like

# keyed hash (AKA: customization)
digest = ::SleepingKangaroo12::Digest.new(key: 'secret')
digest << 'abc' # alternate form of update method
digest.hexdigest
# => "dc1fd53f85402e2b34fa92bd87593dd9c3fe6cc49d9db6c05dc0cf26c6a7e03f"

# shortcuts
::SleepingKangaroo12::Digest.digest('abc')
# => "\xAB\x17O2\x8CU\xA5Q\v\v \x97\x91\xBF\x8B`\xE8\x01\xA7\xCF\xC2\xAAB\x04-\xCB\x8FT\x7F\xBE:}"
::SleepingKangaroo12::Digest.hexdigest('abc', key: 'secret')
# => "dc1fd53f85402e2b34fa92bd87593dd9c3fe6cc49d9db6c05dc0cf26c6a7e03f"
::SleepingKangaroo12::Digest.base64digest('abc', output_length: 24)
# => "qxdPMoxVpVELCyCXkb+LYOgBp8/CqkIE"
# `digest`, `hexdigest`, and `base64digest` are available as shortcuts and also on `Digest` instances.
# Same for the options, you may use `key`, `key_seed`, and `output_length` on both instance methods and shortcuts

# XOF (extendable-output functions)
digest = ::SleepingKangaroo12::Digest.new(output_length: 64)
digest << 'abc'
digest.hexdigest
# => "ab174f328c55a5510b0b209791bf8b60e801a7cfc2aa42042dcb8f547fbe3a7d3f5b54d116a705d36aac2a7eac7a19e3f0f058cb3c238ac7f034178ae34f212e"

# weird parameters
::SleepingKangaroo12::Digest.new(key: 'secret', output_length: 1_000_000_000_000)
# error: Hash length out of range (ArgumentError)
# I arbitrary set the limit of output length at 1MiB - 1 bytes as a safety measure. Same for length <= 0
# If you have a use case for something out of range, feel free to discuss.
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
