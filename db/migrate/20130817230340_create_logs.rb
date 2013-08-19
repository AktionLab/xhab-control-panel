class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string :type
      t.references :component
      t.string :message

      t.timestamps
    end
    add_index :logs, :component_id
  end
end
