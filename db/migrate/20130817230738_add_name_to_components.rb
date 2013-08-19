class AddNameToComponents < ActiveRecord::Migration
  def change
    add_column :components, :name, :string
  end
end
