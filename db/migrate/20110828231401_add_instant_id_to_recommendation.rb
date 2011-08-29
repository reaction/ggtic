class AddInstantIdToRecommendation < ActiveRecord::Migration
  def self.up
    add_column :recommendations, :instant_id, :integer
  end

  def self.down
    remove_column :recommendations, :instant_id
  end
end
