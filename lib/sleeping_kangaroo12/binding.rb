# frozen_string_literal: true

require_relative 'build/loader'

module SleepingKangaroo12
  module Binding
    extend ::FFI::Library
    ffi_lib Build::Loader.find('SleepingKangaroo12')

    attach_function :init, :SleepingKangaroo12_Init, %i[int], :pointer
    attach_function :update, :SleepingKangaroo12_Update, %i[pointer pointer size_t], :int
    attach_function :final, :SleepingKangaroo12_Final, %i[pointer pointer pointer size_t], :int
    attach_function :destroy, :SleepingKangaroo12_Destroy, %i[pointer], :void
  end
end
