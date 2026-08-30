module TrainingExerciseValidations
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_blank_values

    validates :sets, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true, if: -> { respond_to?(:sets) }
    validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true, if: -> { respond_to?(:position) }
    validates :rest, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true, if: -> { respond_to?(:rest) }
  end

  private

  def normalize_blank_values
    self.sets = nil if respond_to?(:sets) && sets.blank?
    self.rest = nil if respond_to?(:rest) && rest.blank?
    self.notes = nil if respond_to?(:notes) && notes.blank?
  end
end
