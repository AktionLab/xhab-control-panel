class CreateData < ActiveRecord::Migration
  def change
    create_table :data do |t|
      t.references :component
      t.float :value

      t.timestamps
    end
    add_index :data, :component_id
  end
end
