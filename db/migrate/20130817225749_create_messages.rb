class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :component
      t.string :text

      t.timestamps
    end
    add_index :messages, :component_id
  end
end
