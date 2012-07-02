class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :title
      t.string :link
       t.string :imgurl
      t.timestamps
    end
  end
end
