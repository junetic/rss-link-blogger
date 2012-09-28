class ChangeStringToText < ActiveRecord::Migration
  def up
 	 change_column :entries, :imgurl, :text, :limit => nil
  end

  def down
  end
end
