module ComponentHelper
  def card(title: nil, footer: nil, css_class: "", &block)
    content = capture(&block)

    card_classes = "bg-white rounded-lg border border-gray-200 shadow-sm p-6 #{css_class}".strip

    content_tag :div, class: card_classes do
      safe_join([
        (content_tag(:h3, title, class: "text-lg font-semibold text-gray-900 mb-4") if title),
        content_tag(:div, content),
        (content_tag(:div, footer, class: "mt-4 pt-4 border-t border-gray-200") if footer)
      ].compact)
    end
  end

  def simple_card(css_class: "", &block)
    content = capture(&block)
    content_tag :div, content, class: "bg-white rounded-lg p-4 #{css_class}".strip
  end

  def stat_card(icon: nil, value:, label:, trend: nil, css_class: "")
    content_tag :div, class: "bg-white rounded-lg border border-gray-200 shadow-sm p-6 #{css_class}".strip do
      safe_join([
        (content_tag(:div, icon(icon, size: "w-8 h-8", css_class: "text-cyan-600"), class: "mb-3") if icon),
        content_tag(:div, class: "flex items-baseline justify-between") do
          safe_join([
            content_tag(:div, class: "flex flex-col") do
              safe_join([
                content_tag(:span, value, class: "text-3xl font-bold text-gray-900"),
                content_tag(:span, label, class: "text-sm text-gray-600 mt-1")
              ])
            end,
            (content_tag(:span, trend, class: trend.start_with?("+") ? "text-green-600 text-sm font-medium" : "text-red-600 text-sm font-medium") if trend)
          ].compact)
        end
      ].compact)
    end
  end

  def alert_card(type: :info, message:, dismissible: false, css_class: "")
    icon_map = {
      info: :info,
      success: :check,
      warning: :warning,
      error: :x
    }

    color_map = {
      info: "bg-blue-50 border-blue-200 text-blue-800",
      success: "bg-green-50 border-green-200 text-green-800",
      warning: "bg-yellow-50 border-yellow-200 text-yellow-800",
      error: "bg-red-50 border-red-200 text-red-800"
    }

    alert_classes = "rounded-lg border p-4 #{color_map[type]} #{css_class}".strip

    content_tag :div, class: alert_classes do
      content_tag :div, class: "flex items-start gap-3" do
        safe_join([
          icon(icon_map[type], size: "w-5 h-5"),
          content_tag(:p, message, class: "flex-1 text-sm"),
          (content_tag(:button, "×", class: "text-lg font-bold opacity-50 hover:opacity-100", onclick: "this.parentElement.parentElement.remove()") if dismissible)
        ].compact)
      end
    end
  end

  def section_header(title, subtitle: nil, css_class: "")
    content_tag :div, class: "mb-6 #{css_class}".strip do
      safe_join([
        content_tag(:h2, title, class: "text-2xl font-bold text-gray-900"),
        (content_tag(:p, subtitle, class: "text-gray-600 mt-1") if subtitle)
      ].compact)
    end
  end
end
