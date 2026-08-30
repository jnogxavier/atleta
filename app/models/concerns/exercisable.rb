module Exercisable
  extend ActiveSupport::Concern

  included do
    has_many :videos, as: :videoable, dependent: :destroy

    validates :name, presence: true
    validates :description, length: { maximum: 1000 }, allow_blank: true
  end
end
