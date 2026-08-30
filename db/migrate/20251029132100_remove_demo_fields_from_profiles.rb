class RemoveDemoFieldsFromProfiles < ActiveRecord::Migration[8.1]
  def change
    remove_column :partner_profiles, :is_demo, :boolean
  end
end
