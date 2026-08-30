# frozen_string_literal: true

class FoodSerializer < ApplicationSerializer
  # Default view - list display
  def default
    attributes(
      id: object.id,
      name: object.name,
      category: object.category,
      energy_kcal: object.energy_kcal,
      protein_g: object.protein_g
    )
  end

  # Summary view - minimal info
  def summary
    attributes(
      id: object.id,
      name: object.name,
      category: object.category
    )
  end

  # Detailed view - full nutritional info
  def detailed
    attributes(
      id: object.id,
      name: object.name,
      category: object.category,
      energy_kcal: object.energy_kcal,
      protein_g: object.protein_g,
      carbohydrate_g: object.carbohydrate_g,
      fat_g: object.fat_g,
      created_at: object.created_at,
      updated_at: object.updated_at
    ).merge(
      total_meals: object.meals.count
    )
  end

  # Admin view - administrative details
  def admin
    detailed
  end
end
