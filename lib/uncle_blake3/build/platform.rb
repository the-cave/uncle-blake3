# frozen_string_literal: true

require 'ffi'
require 'singleton'

module UncleBlake3
  module Build
    # mostly taken from:
    # https://github.com/ffi/ffi-compiler/blob/master/lib/ffi-compiler/platform.rb

    class Platform
      include ::Singleton

      LIBSUFFIX = ::FFI::Platform.mac? ? 'bundle' : ::FFI::Platform::LIBSUFFIX

      def map_library_name(name)
        "#{::FFI::Platform::LIBPREFIX}#{name}.#{LIBSUFFIX}"
      end

      def arch
        ::FFI::Platform::ARCH
      end

      def os
        ::FFI::Platform::OS
      end

      def name
        ::FFI::Platform.name
      end

      def mac?
        ::FFI::Platform.mac?
      end
    end
  end
end
