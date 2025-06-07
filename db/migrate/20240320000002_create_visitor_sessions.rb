class CreateVisitorSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :visitor_sessions do |t|
      t.references :visitor, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :session_id, null: false
      t.datetime :started_at
      t.datetime :ended_at
      t.jsonb :metadata, default: {}
      t.jsonb :page_views, default: {}

      t.timestamps
    end

    add_index :visitor_sessions, [:visitor_id, :session_id], unique: true
  end
end 