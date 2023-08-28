require 'ruby-swagger/object'
require 'ruby-swagger/data/path'

module Swagger::Data
  class Paths < Swagger::Object # https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md#pathsObject
    include Enumerable

    def each(&)
      all_paths.each(&)
    end

    def initialize
      @paths = {}
    end

    def self.parse(paths)
      raise ArgumentError.new('Swagger::Data::Paths#parse - paths object is nil') unless paths
      raise ArgumentError.new('Swagger::Data::Paths#parse - paths object is not an hash') unless paths.is_a?(Hash)

      pts = Swagger::Data::Paths.new

      paths.each do |path, path_obj|
        pts.add_path(path, path_obj)
      end

      pts
    end

    def add_path(path, path_obj)
      raise ArgumentError.new('Swagger::Data::Paths#parse - path is nil') if path.nil? || path.empty?
      raise ArgumentError.new('Swagger::Data::Paths#parse - path object is nil') if path_obj.nil?

      unless path_obj.is_a?(Swagger::Data::Path)
        path_obj = Swagger::Data::Path.parse(path_obj)
      end

      path_obj.path = path
      @paths[path] = path_obj
    end

    def all_paths
      @paths.values
    end

    def [](path)
      @paths[path]
    end

    def to_swagger
      swag_obj = {}

      @paths.each do |path, path_obj|
        swag_obj[path] = path_obj.to_swagger
      end

      swag_obj
    end
  end
end
