require 'yaml'

module YAML
   class PrivateType
      attr_accessor :type_id, :value

      def self.create(type_id, value)
          type = self.allocate
          type.type_id = type_id
          type.value = value
          type
      end

      def ==(other)
         eq? other
      end

      def eq?(other)
         if other.respond_to?(:type_id) && other.respond_to?(:value)
            type_id == other.type_id && value == other.value
         else
            false
         end
      end
   end
end