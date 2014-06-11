class ChangeCallModel < ActiveRecord::Migration
  def up
  	remove_column :calls, :number
  	remove_column :calls, :delay
  	add_column :calls, :number, :string
  	add_column :calls, :delay, :string
  end

  def down
  	remove_column :calls, :number
  	remove_column :calls, :delay
  	add_column :calls, :number, :integer
  	add_column :calls, :delay, :integer
  end
end
