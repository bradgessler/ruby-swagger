require 'ruby-swagger/object'
require 'ruby-swagger/data/external_documentation'
require 'ruby-swagger/data/responses'
require 'ruby-swagger/data/security_requirement'

module Swagger::Data
  class Operation < Swagger::Object # https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md#operationObject
    attr_swagger :tags, :summary, :description, :externalDocs, :operationId,
                 :consumes, :produces, :parameters, :responses,
                 :schemes, :deprecated, :security

    attr_reader :request_method

    def self.parse(operation)
      return unless operation

      Swagger::Data::Operation.new.bulk_set(operation).tap do |operation|
        operation.request_method = operation.to_s.upcase
      end
    end

    def externalDocs=(newDoc)
      return nil unless newDoc

      unless newDoc.is_a?(Swagger::Data::ExternalDocumentation)
        newDoc = Swagger::Data::ExternalDocumentation.parse(newDoc)
      end

      @externalDocs = newDoc
    end

    def responses=(newResp)
      return nil unless newResp

      unless newResp.is_a?(Swagger::Data::Responses)
        newResp = Swagger::Data::Responses.parse(newResp)
      end

      @responses = newResp
    end

    def security=(newSecurity)
      return nil unless newSecurity

      @security = []

      newSecurity.each do |sec_object|
        unless sec_object.is_a?(Swagger::Data::SecurityRequirement)
          sec_object = Swagger::Data::SecurityRequirement.parse(sec_object)
        end

        @security.push(sec_object)
      end
    end

    def parameters=(newParams)
      return nil unless newParams

      @parameters = []

      newParams.each do |parameter|
        add_parameter(parameter)
      end
    end

    def add_parameter(new_parameter)
      @parameters ||= []

      if new_parameter.is_a?(Hash)

        new_parameter = if new_parameter['$ref']
                          # it's a reference object
                          Swagger::Data::Reference.parse(new_parameter)
                        else
                          # it's a parameter object
                          Swagger::Data::Parameter.parse(new_parameter)
                        end

      end

      @parameters.push(new_parameter)
    end
  end
end
