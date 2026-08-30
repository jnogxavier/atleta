class AddRoutineDescriptionToAnamnese < ActiveRecord::Migration[8.1]
  def change
    add_column :anamneses, :routine_description, :text
  end
end
