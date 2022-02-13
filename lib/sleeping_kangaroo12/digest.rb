# frozen_string_literal: true

require_relative 'binding'

module SleepingKangaroo12
  class Digest
    class UpdatingFailed < ::StandardError
    end

    class FinalizationFailed < ::StandardError
    end

    class Finalized < ::StandardError
    end

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

    def update(data)
      raise Finalized if @finalized

      data_size = data.bytesize
      data_buffer = ::FFI::MemoryPointer.new(:char, data_size)
      data_buffer.put_bytes(0, data)
      Binding.update(@native_instance, data_buffer, data_size).tap do |result|
        raise UpdatingFailed unless result.zero?
      end
      nil
    end

    def <<(*args, **kwargs)
      update(*args, **kwargs)
    end

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

    def hexdigest
      @_hexdigest ||= digest.unpack1('H*')
    end

    def base64digest
      @_base64digest ||= ::Base64.strict_encode64(digest)
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

      def _generic_digest(data, output_length: nil, key: nil, &hash_finalizer)
        instance = new(**{ output_length: output_length, key: key }.compact)
        instance.update(data)
        hash_finalizer.call(instance)
      end
    end
  end
end
