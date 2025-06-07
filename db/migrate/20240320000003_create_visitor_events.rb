class CreateVisitorEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :visitor_events do |t|
      t.references :visitor, null: false, foreign_key: true
      t.references :visitor_session, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :event_name, null: false
      t.jsonb :event_data, default: {}

      t.timestamps
    end

    add_index :visitor_events, [:visitor_id, :created_at]
    add_index :visitor_events, [:visitor_session_id, :created_at]
    add_index :visitor_events, [:event_type, :created_at]
  end
end 