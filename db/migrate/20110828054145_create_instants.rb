class CreateInstants < ActiveRecord::Migration
  def self.up
    create_table :instants do |t|
      t.string :title, :unique => true
      t.string :link
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :instants
  end
end
