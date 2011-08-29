class CreateRecommendations < ActiveRecord::Migration
  def self.up
    create_table :recommendations do |t|
      t.string :title
      t.string :link
      t.string :recommended

      t.timestamps
    end
  end

  def self.down
    drop_table :recommendations
  end
end
