# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130715203428) do

  create_table "jenkins_factories", force: true do |t|
    t.string   "factoryName"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jenkins_jobs", force: true do |t|
    t.string   "testname"
    t.string   "username"
    t.string   "password"
    t.string   "displayName"
    t.string   "description"
    t.integer  "factoryID"
    t.string   "url"
    t.string   "LastBuildNum"
    t.string   "buildNum1"
    t.string   "buildNum2"
    t.string   "LastBuildURL"
    t.string   "status"
    t.string   "HealthReportTestStatus"
    t.string   "HealthReportBuildStatus"
    t.string   "lastSuccessfulBuildNum"
    t.integer  "failCount"
    t.integer  "passCount"
    t.integer  "skipCount"
    t.string   "testResults"
    t.string   "OS"
    t.string   "builtOn"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "attached"
    t.string   "lastUpdate"
  end

  create_table "jenkins_builds", force: true do |t|
    t.string   "number"
    t.string   "testname"
    t.string   "url"
    t.string   "username"
    t.string   "password"
    t.integer  "jobID"
    t.string   "causeDescription"
    t.string   "artifacts"
    t.string   "result"
    t.string   "fullDisplayName"
    t.string   "description"
    t.string   "builtOn"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jenkins_machines", force: true do |t|
    t.string   "name"
    t.string   "OS"
    t.string   "password"
    t.string   "username"
    t.string   "testname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
