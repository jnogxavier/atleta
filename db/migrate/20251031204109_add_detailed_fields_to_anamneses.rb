class AddDetailedFieldsToAnamneses < ActiveRecord::Migration[8.1]
  def change
    # Only add the missing columns that don't exist yet
    add_column :anamneses, :cpf, :string unless column_exists?(:anamneses, :cpf)
    add_column :anamneses, :address, :string unless column_exists?(:anamneses, :address)
  end
end
