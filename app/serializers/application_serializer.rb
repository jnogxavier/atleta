# frozen_string_literal: true

# Base serializer for all models
# Provides common serialization methods and conventions following Rails standards
#
# Usage:
#   UserSerializer.render(user)
#   UserSerializer.render(user, view: :detailed)
#   UserSerializer.render_collection(users)
#
# Each serializer defines attributes and views:
#   class UserSerializer < ApplicationSerializer
#     attributes :id, :email, :role
#
#     view :detailed do
#       attributes :id, :email, :role, :created_at, :updated_at
#     end
#   end
class ApplicationSerializer
  # Default attributes included in all views
  attr_reader :object, :options

  def initialize(object, options = {})
    @object = object
    @options = options
  end

  # Render a single object
  # @param object [Object] The object to serialize
  # @param options [Hash] Options including :view
  # @return [Hash] Serialized object
  def self.render(object, options = {})
    return nil if object.nil?
    new(object, options).serialize
  end

  # Render a collection of objects
  # @param collection [Enumerable] Objects to serialize
  # @param options [Hash] Options including :view
  # @return [Array<Hash>] Array of serialized objects
  def self.render_collection(collection, options = {})
    collection.map { |object| render(object, options) }
  end

  # Main serialization method
  # Determines which view to use and delegates to that method
  def serialize
    view_name = options[:view] || :default
    send(view_name)
  end

  # Default view - override in subclasses
  # Should return a Hash with serialized attributes
  def default
    raise NotImplementedError, "#{self.class} must implement #default view"
  end

  protected

  # Helper to build attribute hash with proper handling of nil values and timestamps
  # @param **attrs [Hash] Attributes to include
  # @return [Hash] Cleaned attributes hash
  def attributes(**attrs)
    attrs.each_with_object({}) do |(key, value), hash|
      next if value.nil? && options[:skip_nil]
      hash[key] = format_value(value)
    end
  end

  # Format values for JSON serialization
  # Handles timestamps, booleans, and nested serialization
  def format_value(value)
    case value
    when ActiveSupport::TimeWithZone, Time, DateTime
      value.iso8601
    when Date
      value.iso8601
    when TrueClass, FalseClass, NilClass, Numeric, String
      value
    when Array
      value.map { |item| format_value(item) }
    when Hash
      value.transform_values { |v| format_value(v) }
    else
      # For other objects, try to convert to string or call to_h if available
      value.respond_to?(:to_h) ? format_value(value.to_h) : value.to_s
    end
  end

  # Helper to serialize associations
  # @param association [Object] The association to serialize
  # @param serializer [Class] The serializer class to use
  # @param view [Symbol] The view to use
  # @return [Hash] Serialized association
  def serialize_association(association, serializer, view: :default)
    return nil if association.nil?
    serializer.render(association, view: view)
  end

  # Helper to serialize association collections
  # @param collection [Enumerable] Collection to serialize
  # @param serializer [Class] The serializer class to use
  # @param view [Symbol] The view to use
  # @param **extra_options Additional options to pass to serializer
  # @return [Array<Hash>] Serialized associations
  def serialize_collection(collection, serializer, view: :default, **extra_options)
    return [] if collection.empty?
    render_options = { view: view }.merge(extra_options)
    serializer.render_collection(collection, render_options)
  end

  # Helper to safely call methods on object with fallback
  # @param method [Symbol] Method to call
  # @param fallback [Object] Value to return if method not available
  # @return [Object] Result of method call or fallback
  def safe_call(method, fallback = nil)
    object.respond_to?(method) ? object.send(method) : fallback
  end
end
