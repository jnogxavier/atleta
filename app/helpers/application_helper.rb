module ApplicationHelper
  def flash_class(type)
    case type.to_sym
    when :notice
      "bg-cyan-50 border-cyan-200 text-cyan-800"
    when :alert, :error
      "bg-red-50 border-red-200 text-red-800"
    when :success
      "bg-green-50 border-green-200 text-green-800"
    when :warning
      "bg-yellow-50 border-yellow-200 text-yellow-800"
    else
      "bg-gray-50 border-gray-200 text-gray-800"
    end
  end

  def status_badge(status)
    colors = {
      active: "bg-green-100 text-green-800",
      inactive: "bg-gray-100 text-gray-800",
      pending: "bg-yellow-100 text-yellow-800",
      cancelled: "bg-red-100 text-red-800"
    }

    color_class = colors[status&.to_sym] || colors[:inactive]
    tag.span(status&.titleize || "Unknown", class: "px-2 py-1 rounded-full text-xs font-medium #{color_class}")
  end

  def icon_svg(type, css_class: "w-5 h-5")
    icons = {
      check: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>',
      x: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>',
      info: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>',
      warning: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>'
    }

    path = icons[type.to_sym] || icons[:info]
    tag.svg(path.html_safe, class: "#{css_class}", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24")
  end

  def smart_truncate(text, length: 100)
    return "" unless text
    text.length > length ? "#{text[0...length]}..." : text
  end

  def field_has_error?(object, field)
    object&.errors&.[](field)&.any?
  end

  def field_error_class(object, field, base_class:)
    if field_has_error?(object, field)
      "#{base_class} border-red-500 focus:ring-red-400 focus:border-red-400"
    else
      base_class
    end
  end

  def field_error_message(object, field)
    return unless field_has_error?(object, field)
    tag.p(object.errors[field].first, class: "mt-1 text-sm text-red-600")
  end

  def required_field_label(text, object, field, form_builder = nil)
    validators = object.class.validators_on(field)

    has_presence = validators.any? { |v| v.is_a?(ActiveRecord::Validations::PresenceValidator) }

    has_required_inclusion = validators.any? do |v|
      v.is_a?(ActiveModel::Validations::InclusionValidator) && !v.options[:allow_nil]
    end

    is_required = has_presence || has_required_inclusion

    field_id = if form_builder
      "#{form_builder.object_name}_#{field}".gsub(/[\[\]]/, "_").gsub(/__+/, "_").gsub(/_$/, "")
    else
      field.to_s
    end

    if is_required
      tag.label(for: field_id, class: "block text-sm font-medium text-gray-700 mb-2") do
        concat text
        concat " "
        concat tag.span("*", class: "text-gray-700")
      end
    else
      tag.label(text, for: field_id, class: "block text-sm font-medium text-gray-700 mb-2")
    end
  end

  def normalize_text(text)
    return "" if text.blank?
    I18n.transliterate(text)
      .downcase
      .gsub(/[,.:;\-()]/, " ")
      .gsub(/\s+/, " ")
      .strip
  end

  def format_error_message(error)
    attr_str = error.attribute.to_s
    message = error.message

    # Extract field name from different attribute formats
    field_name = if attr_str.include?("anamnese_attributes[")
      # Extract from "anamnese_attributes[bowel_movement_scale]" → "bowel_movement_scale"
      match = attr_str.match(/anamnese_attributes\[([^\]]+)\]/)
      match ? match[1] : attr_str
    elsif attr_str.include?(".")
      attr_str.split(".").last
    elsif attr_str.include?("_attributes")
      attr_str.gsub("anamnese_attributes[", "").gsub("]", "")
    else
      attr_str
    end

    # Get translated attribute name from locale
    attr_name = I18n.t("activerecord.attributes.anamnese.#{field_name}", default: field_name.humanize)

    "#{attr_name} #{message}"
  end

  def progress_width_class(percentage)
    case percentage
    when 0
      "w-0"
    when 1..10
      "w-1/12"
    when 11..20
      "w-1/6"
    when 21..30
      "w-1/4"
    when 31..40
      "w-1/3"
    when 41..50
      "w-1/2"
    when 51..60
      "w-7/12"
    when 61..70
      "w-2/3"
    when 71..80
      "w-3/4"
    when 81..90
      "w-5/6"
    when 91..99
      "w-11/12"
    else
      "w-full"
    end
  end

  def format_nutrition_plan_errors(nutrition_plan)
    return [] unless nutrition_plan.errors.any?

    nutrition_plan.errors.messages.flat_map do |attr, messages|
      messages.map do |message|
        attr_str = attr.to_s

        # Handle nested dot notation: meals.meal_foods.quantity_grams
        if attr_str.include?("meals.meal_foods.")
          "Alimento - #{message}"
        elsif attr_str.include?("meals.")
          "Refeição - #{message}"
        else
          "#{attr_str.humanize} #{message}"
        end
      end
    end
  end

  # Query helper methods for global use
  # Instance methods for use in views/controllers
  def normalize_search(query)
    query.to_s.strip.downcase
  end

  def sanitize_sql_like(string)
    string.to_s.gsub(/[%_\\]/) { |match| "\\#{match}" }
  end

  def parse_integer(value)
    return nil unless value.present?
    parsed = value.to_s.gsub(/[^\d]/, "").to_i
    parsed > 0 ? parsed : nil
  end

  def build_search_query(search_string)
    "%#{sanitize_sql_like(search_string)}%"
  end

  # Class methods for use in services/models
  class << self
    def normalize_search(query)
      query.to_s.strip.downcase
    end

    def sanitize_sql_like(string)
      string.to_s.gsub(/[%_\\]/) { |match| "\\#{match}" }
    end

    def parse_integer(value)
      return nil unless value.present?
      parsed = value.to_s.gsub(/[^\d]/, "").to_i
      parsed > 0 ? parsed : nil
    end

    def build_search_query(search_string)
      "%#{sanitize_sql_like(search_string)}%"
    end
  end
end
