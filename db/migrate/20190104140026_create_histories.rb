class CreateHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :histories do |t|
      t.string :title
      t.integer :repeat

      t.timestamps
    end
  end
end
