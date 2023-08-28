require 'ruby-swagger/object'
require 'ruby-swagger/data/operation'
require 'ruby-swagger/data/parameter'
require 'ruby-swagger/data/reference'

module Swagger::Data
  class Path < Swagger::Object # https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md#path-item-object
    attr_swagger :get, :put, :post, :delete, :options, :head, :patch, :parameters # and $ref
    attr_accessor :path
    @ref = nil

    def self.parse(path)
      raise ArgumentError.new('Swagger::Data::Path - path is nil') unless path

      res = Swagger::Data::Path.new.bulk_set(path)
      res.ref = path['$ref'] if path['$ref']
      res
    end

    def all_methods
      [@get, @put, @post, @delete, @options, @head, @patch].compact
    end
    alias :request_methods :all_methods
    alias :operations :all_methods

    def get=(new_get)
      @get = build_operation "GET", new_get
    end

    def put=(new_put)
      @put = build_operation "PUT", new_put
    end

    def post=(new_post)
      @post = build_operation "POST", new_post
    end

    def delete=(new_delete)
      @delete = build_operation "DELETE", new_delete
    end

    def options=(new_options)
      @options = build_operation "OPTIONS", new_options
    end

    def head=(new_head)
      @head = build_operation "HEAD", new_head
    end

    def patch=(new_patch)
      @patch = build_operation "PATCH", new_patch
    end

    def parameters=(new_parameters)
      return nil unless new_parameters
      raise ArgumentError.new('Swagger::Data::Path#parameters= - parameters is not an array') unless new_parameters.is_a?(Array)

      @parameters = []

      new_parameters.each do |parameter|
        new_param = if parameter['$ref']
                      # it's a reference object
                      Swagger::Data::Reference.parse(parameter)
                    else
                      # it's a parameter object
                      Swagger::Data::Parameter.parse(parameter)
                    end

        @parameters.push(new_param)
      end
    end

    def ref=(new_ref)
      return nil unless new_ref
      raise ArgumentError.new('Swagger::Data::Path#ref= - $ref is not a string') unless new_ref.is_a?(String)

      @ref = new_ref
    end

    attr_reader :ref

    def as_swagger
      res = super
      res['$ref'] = @ref if @ref
      res
    end

    protected

    def build_operation(request_method, operation)
      return nil unless operation
      unless operation.is_a?(Swagger::Data::Operation)
        operation = Swagger::Data::Operation.parse(operation)
        operation.request_method = request_method.freeze
      end
      operation
    end
  end
end
