# frozen_string_literal: true

require 'base64'
require 'ffi'
require 'objspace'
require_relative 'binding'

module UncleBlake3
  # @example basic usage
  #   digest = ::UncleBlake3::Digest.new(output_length: 10)
  #   digest << 'some input'
  #   digest << 'some more input'
  #   digest.hexdigest
  #   #=> "d709fca62bbf74099e87"
  # See {file:README.md README} for more usage examples
  class Digest
    KEY_LENGTH = Binding.key_length
    DEFAULT_OUTPUT_LENGTH = Binding.default_output_length

    module Error
    end

    class ArgumentError < ::ArgumentError
      include Error
    end

    class TypeError < ::TypeError
      include Error
    end

    # Create a new Digest
    def initialize(output_length: DEFAULT_OUTPUT_LENGTH, key: nil, key_seed: nil)
      raise TypeError, 'Hash length is not an Integer' unless output_length.is_a?(::Integer)
      raise ArgumentError, 'Hash length out of range' unless (1...(1 << 20)).include?(output_length)
      raise TypeError, 'Key is not a String' if !key.nil? && !key.is_a?(::String)
      raise ArgumentError, 'Key length mismatched' unless key.nil? || (key.bytesize == KEY_LENGTH)
      raise TypeError, 'Key seed is not a String' if !key_seed.nil? && !key_seed.is_a?(::String)
      @native_instance = if !key && !key_seed
        Binding.init
      elsif key && key_seed
        raise ::ArgumentError, 'Both key and key_seed available at the same time; please pick only one.'
      elsif key
        key_buffer = ::FFI::MemoryPointer.new(:uint8, KEY_LENGTH)
        key_buffer.put_bytes(0, key)
        Binding.init_with_key(key_buffer)
      elsif key_seed
        seed_size = key_seed.bytesize
        seed_buffer = ::FFI::MemoryPointer.new(:uint8, seed_size)
        seed_buffer.put_bytes(0, key_seed)
        Binding.init_with_key_seed(seed_buffer, seed_size)
      else
        raise ::ArgumentError, 'Unknown mode of operation'
      end.tap do |pointer|
        ::ObjectSpace.define_finalizer(self, self.class._create_finalizer(pointer))
      end
      @output_length = output_length
      invalidate_cache
    end

    # Feed in the data
    def update(data)
      data_size = data.bytesize
      data_buffer = ::FFI::MemoryPointer.new(:uint8, data_size)
      data_buffer.put_bytes(0, data)
      Binding.update(@native_instance, data_buffer, data_size)
      self
    ensure
      invalidate_cache
    end

    # Alias for {#update}
    def <<(*args, **kwargs)
      update(*args, **kwargs)
    end

    # Finalize and output a binary hash
    def digest
      @_digest_cache ||= begin
        data_buffer = ::FFI::MemoryPointer.new(:uint8, @output_length)
        Binding.final(@native_instance, data_buffer, @output_length)
        data_buffer.get_bytes(0, @output_length)
      end
    end

    # Finalize and output a hexadecimal-encoded hash
    def hexdigest
      @_hexdigest_cache ||= digest.unpack1('H*')
    end

    # Finalize and output a Base64-encoded hash
    def base64digest
      @_base64digest_cache ||= ::Base64.strict_encode64(digest)
    end

    private

    def invalidate_cache
      @_digest_cache = nil
      @_hexdigest_cache = nil
      @_base64digest_cache = nil
    end

    class << self
      # @!visibility private
      # https://www.mikeperham.com/2010/02/24/the-trouble-with-ruby-finalizers/
      def _create_finalizer(instance)
        proc do
          Binding.destroy(instance)
        end
      end

      # Shortcut to calculate a raw digest
      # @example basic usage
      #   ::UncleBlake3::Digest.digest('some input')
      #   #=> "{7\x00\f\x00EZ\xBD \x9A\x9A\x02\xDDH|>({\xC6\xA1\x9DNA\xEB\x81\xC8K\x85\x9E\xBF\x87;"
      # @example with key derived from seed
      #   ::UncleBlake3::Digest.digest('some input', key_seed: 'secret')
      #   #=> "\xA7d\x13c)e\e`>\x9D\e\xB0\x9E\xF9\xA6\x82F:\xA8w;\xB0!\xBC*l\xF3w\x83\x85\xCA\x1E"
      # @example with raw key (fixed-length key)
      #   ::UncleBlake3::Digest.digest('some input', key: '0123456789abcdef0123456789abcdef')
      #   #=> "8Z\x89+\x1A}\x0E\xBBI\xD4)\xC5\x9A\x8A\x17\x13[\xB7\x1DO\x98\xE8\xEF\x06\xD58\x83c\xC3u\x13\xE1"
      # @example controlled output length
      #   ::UncleBlake3::Digest.digest('some input', output_length: 5)
      #   #=> "{7\x00\f\x00"
      def digest(*args, **kwargs)
        _generic_digest(*args, **kwargs, &:digest)
      end

      # Same as {.digest} but encode the output in hexadecimal format
      def hexdigest(*args, **kwargs)
        _generic_digest(*args, **kwargs, &:hexdigest)
      end

      # Same as {.digest} but encode the output in Base64 format
      def base64digest(*args, **kwargs)
        _generic_digest(*args, **kwargs, &:base64digest)
      end

      private

      def _generic_digest(data, output_length: nil, key: nil, key_seed: nil, &hash_finalizer)
        instance = new(**{ output_length: output_length, key: key, key_seed: key_seed }.compact)
        instance.update(data)
        hash_finalizer.call(instance)
      end
    end
  end
end
