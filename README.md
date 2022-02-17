# UncleBlake3

## What is it?

UncleBlake3 is a Ruby binding of [Blake3](https://github.com/BLAKE3-team/BLAKE3), a fast cryptographic hash function.

## What are specials?

- It builds on top of the [official C implementation](https://github.com/BLAKE3-team/BLAKE3/tree/master/c),
  which is hand-optimized down to the assembly instruction.
- The implementation supports `AVX512`, `AVX2`, `SSE4.1`, and `SSE2` instruction set for accelerations.
- Thin and stable binding layer
- Not limited to [Matz's Ruby Interpreter (MRI)](https://en.wikipedia.org/wiki/Ruby_MRI), this is due to the gem opting
  for [Ruby-FFI](https://github.com/ffi/ffi) instead of using the API exposed by `ruby.h`.
  (I only tested on MRI, though.)

## Prerequisites

In order to install the gem, your needs:

- GCC, the GNU Compiler Collection
- And Ruby related stuffs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'uncle_blake3'
```

And then execute:

    $ bundle install

## Usage Examples

~~~Ruby
# basic usage
::UncleBlake3::Digest.hexdigest("\x00")
# => "2d3adedff11b61f14c886e35afa036736dcd87a74d27b5c1510225d0f592e213"

# streaming
digest = ::UncleBlake3::Digest.new
digest << "\x00\x01"
digest << "\x02\x03"
digest.hexdigest
# => "f30f5ab28fe047904037f77b6da4fea1e27241c5d132638d8bedce9d40494f32"
# `<<` is an alias of `update`, use the one you like

# keyed hash
digest = ::UncleBlake3::Digest.new(key: 'whats the Elvish word for friend') # the key must be a 32-byte key or UncleBlake will get mad
digest << "\x00\x01\x02\x03"
digest.hexdigest
# => "7671dde590c95d5ac9616651ff5aa0a27bee5913a348e053b8aa9108917fe070"

# use key_seed if you want something like a keyed hash but you have an arbitrary length String as a key
digest = ::UncleBlake3::Digest.new(key_seed: 'BLAKE3 2019-12-27 16:29:52 test vectors context') # key_seed is the context string in the derive_key mode of Blake3
digest << "\x00\x01\x02\x03"
digest.hexdigest
# => "f46085c8190d69022369ce1a18880e9b369c135eb93f3c63550d3e7630e91060"

# shortcuts
::UncleBlake3::Digest.digest("\x00\x01\x02\x03", key_seed: 'BLAKE3 2019-12-27 16:29:52 test vectors context')
# => "\xF4`\x85\xC8\x19\ri\x02#i\xCE\x1A\x18\x88\x0E\x9B6\x9C\x13^\xB9?<cU\r>v0\xE9\x10`"
::UncleBlake3::Digest.hexdigest("\x00\x01\x02\x03", key_seed: 'BLAKE3 2019-12-27 16:29:52 test vectors context')
# => "f46085c8190d69022369ce1a18880e9b369c135eb93f3c63550d3e7630e91060"
::UncleBlake3::Digest.base64digest("\x00\x01\x02\x03", key_seed: 'BLAKE3 2019-12-27 16:29:52 test vectors context', output_length: 24)
# => "9GCFyBkNaQIjac4aGIgOmzacE165Pzxj"
# `digest`, `hexdigest`, and `base64digest` are available as shortcuts and also on `Digest` instances.
# Same for the options, you may use `key`, `key_seed`, and `output_length` on both instance methods and shortcuts

# XOF (extendable-output functions)
digest = ::UncleBlake3::Digest.new(output_length: 64)
digest << "\x00"
digest.hexdigest
# => "2d3adedff11b61f14c886e35afa036736dcd87a74d27b5c1510225d0f592e213c3a6cb8bf623e20cdb535f8d1a5ffb86342d9c0b64aca3bce1d31f60adfa137b"
~~~

## Why not Rust binding?

`gcc` is way more common than `rust` compiler.  
Also in a typical Ruby application, we usually don't hash tons of data; mostly just hashing short messages.  
In such case, C might me the best choice usability wise and performance wise, due to the fact that it only calculate a single hash on a single thread.
We won't get multicore boost on a single hash calculation, but with many simultaneous calculation for short inputs, we will get the benefit with less overhead.

## License

UncleBlake3 is released under the [BSD 3-Clause License](LICENSE.md). :tada:
