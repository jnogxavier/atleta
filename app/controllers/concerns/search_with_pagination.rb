module SearchWithPagination
  extend ActiveSupport::Concern

  def perform_search_with_pagination(relation, search_fields, **options)
    search_query = params[options[:search_param] || :search].to_s.strip
    per_page = options[:per_page] || 10
    partial_name = options[:partial_name]
    pagination_partial_name = options[:pagination_partial_name]
    locals = options[:locals] || {}
    join_tables = options[:join_tables] || []

    if search_query.present?
      search_conditions = search_fields.map { |field| "LOWER(#{field}) LIKE LOWER(?)" }.join(" OR ")
      search_values = Array.new(search_fields.length, "%#{search_query}%")

      join_tables.each { |table| relation = relation.joins(table) }

      relation = relation.where(search_conditions, *search_values)
    end

    paginated_results = relation
      .order(created_at: :desc)
      .page(params[:page])
      .per(per_page)

    pagination_html = if paginated_results.total_pages > 1
      pagination_locals = case pagination_partial_name
      when "admin/dashboard/pagination"
                            { approved_students: paginated_results, search_query: search_query }
      when "admin/dashboard/nutrition_pagination"
                            { nutrition_plans: paginated_results, search_query: search_query }
      else
                            { paginated_results: paginated_results, search_query: search_query }
      end

      render_to_string(
        partial: pagination_partial_name,
        formats: [ :html ],
        locals: pagination_locals
      )
    else
      ""
    end

    render json: {
      html: render_to_string(
        partial: partial_name,
        formats: [ :html ],
        locals: { paginated_results: paginated_results }
      ),
      pagination_html: pagination_html,
      total_count: paginated_results.total_count,
      total_pages: paginated_results.total_pages,
      current_page: paginated_results.current_page
    }
  end
end
