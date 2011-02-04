class AddSuggestedAgingToBrew < ActiveRecord::Migration
  def self.up
    add_column :brews, :suggested_aging_years, :integer
    add_column :brews, :suggested_aging_months, :integer
  end

  def self.down
    remove_column :brews, :suggested_aging_months
    remove_column :brews, :suggested_aging_years
  end
end
