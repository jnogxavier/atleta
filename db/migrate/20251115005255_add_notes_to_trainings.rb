class AddNotesToTrainings < ActiveRecord::Migration[8.1]
  def change
    add_column :trainings, :notes, :text
  end
end
