require 'ruby-swagger/object'
require 'ruby-swagger/data/schema'

module Swagger::Data
  class Definitions < Swagger::Object # https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md#definitionsObject
    include Enumerable

    def each(&)
      @definitions.values.each(&)
    end

    def initialize
      @definitions = {}
    end

    def self.parse(definitions)
      return nil unless definitions

      definition = Swagger::Data::Definitions.new

      definitions.each do |definition_name, definition_value|
        definition.add_definition(definition_name, definition_value)
      end

      definition
    end

    def add_definition(definition_name, definition_value)
      raise ArgumentError.new('Swagger::Data::Definitions#add_definition - definition_name is nil') unless definition_name
      raise ArgumentError.new('Swagger::Data::Definitions#add_definition - definition_value is nil') unless definition_value

      unless definition_value.is_a?(Swagger::Data::Schema)
        definition_value = Swagger::Data::Schema.parse(definition_value)
      end

      @definitions[definition_name] = definition_value
    end

    def [](key)
      # Schema's always have a ref, so let's just unpack that if an object
      # is given to us that responds to schema.
      return self[key.schema] if key.respond_to? :schema
      # If we pass and object in here that responses to ref, like Schema, call
      # the ref method and continue on our merry way.
      return self[key.ref] if key.respond_to? :ref
      # Removes the leading `/#definitions/` from the string
      # since this library stores everything after that as the key.
      case key
      when String
        key = key.sub(/\A#\/definitions\//, "")
        @definitions[key]
      when NilClass
        nil
      else
        raise "Expecting #{key.inspect} to be a string"
      end
    end

    def as_swagger
      swagger_defs = {}

      @definitions.each do |def_k, def_v|
        swagger_defs[def_k] = def_v.to_swagger
      end

      swagger_defs
    end
  end
end
