# frozen_string_literal: true

require 'base64'
require 'ffi'
require 'objspace'
require_relative 'binding'

module SleepingKangaroo12
  # @example basic usage
  #   digest = ::SleepingKangaroo12::Digest.new(output_length: 10)
  #   digest << 'some input'
  #   digest << 'some more input'
  #   digest.hexdigest
  #   #=> "cbea8144fbbf6150ceaf"
  # See {file:README.md README} for more examples
  class Digest
    module Error
    end

    class UpdatingFailed < ::StandardError
      include Error
    end

    class FinalizationFailed < ::StandardError
      include Error
    end

    class Finalized < ::StandardError
      include Error
    end

    # Create a new Digest
    def initialize(output_length: 32, key: nil)
      raise ::TypeError, 'Hash length is not an Integer' unless output_length.is_a?(::Integer)
      raise ::ArgumentError, 'Hash length out of range' unless (1...(1 << 20)).include?(output_length)
      raise ::TypeError, 'Key is not a String' if !key.nil? && !key.is_a?(::String)

      # id = SecureRandom.uuid
      @native_instance = Binding.init(output_length).tap do |pointer|
        ::ObjectSpace.define_finalizer(self, self.class._create_finalizer(pointer))
      end
      @output_length = output_length
      @key = key
      @finalized = false
      @result = nil
    end

    # Feed in the data
    def update(data)
      raise Finalized if @finalized
      data_size = data.bytesize
      data_buffer = ::FFI::MemoryPointer.new(:char, data_size)
      data_buffer.put_bytes(0, data)
      Binding.update(@native_instance, data_buffer, data_size).tap do |result|
        raise UpdatingFailed unless result.zero?
      end
      self
    end

    # Alias for {#update}
    def <<(*args, **kwargs)
      update(*args, **kwargs)
    end

    # Finalize and output a binary hash
    def digest
      @finalized = true
      return @_digest if @_digest

      data_buffer = ::FFI::MemoryPointer.new(:char, @output_length)
      customization_buffer, customization_size = @key.then do |key|
        next [::FFI::MemoryPointer.new(:char, 0), 0] unless key

        size = key.bytesize
        [::FFI::MemoryPointer.new(:char, size).tap do |buffer|
          buffer.put_bytes(0, key)
        end, size]
      end
      Binding.final(@native_instance, data_buffer, customization_buffer, customization_size).tap do |result|
        raise FinalizationFailed unless result.zero?
      end
      @_digest = data_buffer.get_bytes(0, @output_length)
    end

    # Finalize and output a hexadecimal-encoded hash
    def hexdigest
      @_hexdigest ||= digest.unpack1('H*')
    end

    # Finalize and output a Base64-encoded hash
    def base64digest
      @_base64digest ||= ::Base64.strict_encode64(digest)
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
      #   ::SleepingKangaroo12::Digest.digest('some input')
      #   #=> "m\x9FJ\xDA\xE9\x96\xD1X\xC5K\xE83e(x\x8C\xD3o\xFBh\xB2\x17W ,\xD5\xED!\xE4D\xAF\xDD"
      # @example with key (AKA: customization)
      #   ::SleepingKangaroo12::Digest.digest('some input', key: 'secret')
      #   #=> "\x96\xE2K\xC4\xCF\xFFGF\xE1\x05\xB9\xF6f\xF0-\xF8\x1F\a\n\xFC\xD7\xC9\x91\n\xFC\xFB\xA6hOx\x99<"
      # @example controlled output length
      #   ::SleepingKangaroo12::Digest.digest('some input', output_length: 5)
      #   #=> "m\x9FJ\xDA\xE9"
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

      def _generic_digest(data, output_length: nil, key: nil, &hash_finalizer)
        instance = new(**{ output_length: output_length, key: key }.compact)
        instance.update(data)
        hash_finalizer.call(instance)
      end
    end
  end
end
