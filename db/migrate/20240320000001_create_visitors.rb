class CreateVisitors < ActiveRecord::Migration[7.0]
  def change
    create_table :visitors do |t|
      t.references :account, null: false, foreign_key: true
      t.string :visitor_id, null: false
      t.jsonb :location_data, default: {}
      t.jsonb :device_data, default: {}
      t.jsonb :utm_data, default: {}

      t.timestamps
    end

    add_index :visitors, [:account_id, :visitor_id], unique: true
  end
end 