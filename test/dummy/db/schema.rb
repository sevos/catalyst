# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 5) do
  create_table "application_agents", force: :cascade do |t|
    t.string "role"
    t.text "goal"
    t.text "backstory"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "catalyst_agents", force: :cascade do |t|
    t.string "agentable_type", null: false
    t.bigint "agentable_id", null: false
    t.integer "max_iterations", default: 5, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "model"
    t.text "model_params"
    t.index [ "agentable_type", "agentable_id" ], name: "index_catalyst_agents_on_agentable", unique: true
  end

  create_table "catalyst_executions", force: :cascade do |t|
    t.integer "agent_id", null: false
    t.string "status", null: false
    t.text "prompt", null: false
    t.text "result"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "error_message"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.index [ "agent_id" ], name: "index_catalyst_executions_on_agent_id"
  end

  add_foreign_key "catalyst_executions", "catalyst_agents", column: "agent_id"
end
