class AddAuthorToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :author, :string
  end
end
