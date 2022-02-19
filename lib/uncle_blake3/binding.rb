# frozen_string_literal: true

require_relative 'build/loader'

module UncleBlake3
  module Binding
    extend ::FFI::Library
    ffi_lib Build::Loader.find('UncleBlake3')

    attach_function :key_length, :UncleBlake3_KEY_LEN, %i[], :uint16
    attach_function :default_output_length, :UncleBlake3_OUT_LEN, %i[], :uint16

    attach_function :init, :UncleBlake3_Init, %i[], :pointer
    attach_function :init_with_key, :UncleBlake3_InitWithKey, %i[pointer], :pointer
    attach_function :init_with_key_seed, :UncleBlake3_InitWithKeySeed, %i[pointer size_t], :pointer
    attach_function :update, :UncleBlake3_Update, %i[pointer pointer size_t], :int
    attach_function :final, :UncleBlake3_Final, %i[pointer pointer size_t], :int
    attach_function :destroy, :UncleBlake3_Destroy, %i[pointer], :void
  end
end
