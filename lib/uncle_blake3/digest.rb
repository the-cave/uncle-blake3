# frozen_string_literal: true

require 'base64'
require 'ffi'
require 'objspace'
require_relative 'binding'

module UncleBlake3
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

    def update(data)
      data_size = data.bytesize
      data_buffer = ::FFI::MemoryPointer.new(:uint8, data_size)
      data_buffer.put_bytes(0, data)
      Binding.update(@native_instance, data_buffer, data_size)
      self
    ensure
      invalidate_cache
    end

    def <<(*args, **kwargs)
      update(*args, **kwargs)
    end

    def digest
      @_digest_cache ||= begin
        data_buffer = ::FFI::MemoryPointer.new(:uint8, @output_length)
        Binding.final(@native_instance, data_buffer, @output_length)
        data_buffer.get_bytes(0, @output_length)
      end
    end

    def hexdigest
      @_hexdigest_cache ||= digest.unpack1('H*')
    end

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
      # https://www.mikeperham.com/2010/02/24/the-trouble-with-ruby-finalizers/
      def _create_finalizer(instance)
        proc {
          Binding.destroy(instance)
        }
      end

      def digest(*args, **kwargs)
        _generic_digest(*args, **kwargs, &:digest)
      end

      def hexdigest(*args, **kwargs)
        _generic_digest(*args, **kwargs, &:hexdigest)
      end

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
