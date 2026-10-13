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

ActiveRecord::Schema[8.1].define(version: 2026_10_09_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "announcements", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.string "target", default: "all", null: false
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "assignment_discussions", force: :cascade do |t|
    t.bigint "assignment_id", null: false
    t.bigint "user_id", null: false
    t.bigint "parent_id"
    t.text "message", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_assignment_discussions_on_assignment_id"
    t.index ["parent_id"], name: "index_assignment_discussions_on_parent_id"
    t.index ["user_id"], name: "index_assignment_discussions_on_user_id"
  end

  create_table "assignment_submissions", force: :cascade do |t|
    t.bigint "assignment_id", null: false
    t.bigint "student_id", null: false
    t.string "file_path"
    t.text "notes"
    t.decimal "score", precision: 5, scale: 2
    t.text "feedback"
    t.string "status", default: "submitted", null: false
    t.datetime "submitted_at", null: false
    t.datetime "graded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id", "student_id"], name: "index_assignment_submissions_on_assignment_id_and_student_id", unique: true
    t.index ["assignment_id"], name: "index_assignment_submissions_on_assignment_id"
    t.index ["student_id"], name: "index_assignment_submissions_on_student_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.bigint "teacher_id", null: false
    t.bigint "subject_id", null: false
    t.bigint "classroom_id", null: false
    t.string "title", null: false
    t.text "description"
    t.text "instructions"
    t.integer "max_score", default: 100, null: false
    t.datetime "due_date", null: false
    t.boolean "allow_late_submission", default: false, null: false
    t.string "status", default: "published", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_assignments_on_classroom_id"
    t.index ["subject_id"], name: "index_assignments_on_subject_id"
    t.index ["teacher_id"], name: "index_assignments_on_teacher_id"
  end

  create_table "classrooms", force: :cascade do |t|
    t.string "name", null: false
    t.integer "level", default: 10, null: false
    t.integer "capacity", default: 36, null: false
    t.string "academic_year", default: "2025/2026", null: false
    t.bigint "homeroom_teacher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["homeroom_teacher_id"], name: "index_classrooms_on_homeroom_teacher_id"
    t.index ["name"], name: "index_classrooms_on_name"
  end

  create_table "exam_answers", force: :cascade do |t|
    t.bigint "exam_attempt_id", null: false
    t.bigint "question_id", null: false
    t.text "student_answer"
    t.boolean "is_correct"
    t.decimal "points_awarded", precision: 5, scale: 2, default: "0.0"
    t.datetime "graded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exam_attempt_id", "question_id"], name: "index_exam_answers_on_exam_attempt_id_and_question_id", unique: true
    t.index ["exam_attempt_id"], name: "index_exam_answers_on_exam_attempt_id"
    t.index ["question_id"], name: "index_exam_answers_on_question_id"
  end

  create_table "exam_attempts", force: :cascade do |t|
    t.bigint "examination_id", null: false
    t.bigint "student_id", null: false
    t.string "status", default: "in_progress", null: false
    t.decimal "score", precision: 5, scale: 2
    t.boolean "passed"
    t.integer "violations_count", default: 0, null: false
    t.datetime "started_at", null: false
    t.datetime "finished_at"
    t.integer "remaining_seconds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["examination_id"], name: "index_exam_attempts_on_examination_id"
    t.index ["student_id"], name: "index_exam_attempts_on_student_id"
  end

  create_table "examinations", force: :cascade do |t|
    t.bigint "teacher_id", null: false
    t.bigint "subject_id", null: false
    t.bigint "classroom_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "exam_type", default: "quiz", null: false
    t.integer "duration_minutes", default: 60, null: false
    t.decimal "passing_score", precision: 5, scale: 2, default: "75.0", null: false
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean "shuffle_questions", default: false, null: false
    t.boolean "shuffle_options", default: false, null: false
    t.boolean "show_result", default: true, null: false
    t.boolean "allow_retry", default: false, null: false
    t.string "status", default: "draft", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_examinations_on_classroom_id"
    t.index ["subject_id"], name: "index_examinations_on_subject_id"
    t.index ["teacher_id"], name: "index_examinations_on_teacher_id"
  end

  create_table "learning_materials", force: :cascade do |t|
    t.bigint "teacher_id", null: false
    t.bigint "subject_id", null: false
    t.bigint "classroom_id"
    t.string "title", null: false
    t.text "description"
    t.string "material_type", default: "document", null: false
    t.text "content"
    t.string "file_url"
    t.string "file_path"
    t.boolean "published", default: true, null: false
    t.integer "total_views", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_learning_materials_on_classroom_id"
    t.index ["subject_id"], name: "index_learning_materials_on_subject_id"
    t.index ["teacher_id"], name: "index_learning_materials_on_teacher_id"
  end

  create_table "material_views", force: :cascade do |t|
    t.bigint "learning_material_id", null: false
    t.bigint "student_id", null: false
    t.datetime "viewed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["learning_material_id", "student_id"], name: "index_material_views_on_learning_material_id_and_student_id", unique: true
    t.index ["learning_material_id"], name: "index_material_views_on_learning_material_id"
    t.index ["student_id"], name: "index_material_views_on_student_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "examination_id", null: false
    t.text "question_text", null: false
    t.string "question_type", default: "multiple_choice", null: false
    t.jsonb "options", default: []
    t.integer "points", default: 10, null: false
    t.string "difficulty", default: "medium", null: false
    t.string "correct_answer"
    t.text "explanation"
    t.string "image_path"
    t.string "audio_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["examination_id"], name: "index_questions_on_examination_id"
  end

  create_table "students", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "classroom_id"
    t.string "nis", null: false
    t.string "nisn"
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "gender", default: "M", null: false
    t.date "birth_date"
    t.text "address"
    t.string "photo"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_students_on_classroom_id"
    t.index ["nis"], name: "index_students_on_nis", unique: true
    t.index ["user_id"], name: "index_students_on_user_id", unique: true
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.text "description"
    t.bigint "teacher_id"
    t.integer "credits", default: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_subjects_on_code", unique: true
    t.index ["teacher_id"], name: "index_subjects_on_teacher_id"
  end

  create_table "teachers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "nip", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.text "address"
    t.string "photo"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nip"], name: "index_teachers_on_nip", unique: true
    t.index ["user_id"], name: "index_teachers_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "ROLE_STUDENT", null: false
    t.boolean "active", default: true, null: false
    t.bigint "impersonated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "assignment_discussions", "assignment_discussions", column: "parent_id"
  add_foreign_key "assignment_discussions", "assignments"
  add_foreign_key "assignment_discussions", "users"
  add_foreign_key "assignment_submissions", "assignments"
  add_foreign_key "assignment_submissions", "students"
  add_foreign_key "assignments", "classrooms"
  add_foreign_key "assignments", "subjects"
  add_foreign_key "assignments", "teachers"
  add_foreign_key "classrooms", "teachers", column: "homeroom_teacher_id"
  add_foreign_key "exam_answers", "exam_attempts"
  add_foreign_key "exam_answers", "questions"
  add_foreign_key "exam_attempts", "examinations"
  add_foreign_key "exam_attempts", "students"
  add_foreign_key "examinations", "classrooms"
  add_foreign_key "examinations", "subjects"
  add_foreign_key "examinations", "teachers"
  add_foreign_key "learning_materials", "classrooms"
  add_foreign_key "learning_materials", "subjects"
  add_foreign_key "learning_materials", "teachers"
  add_foreign_key "material_views", "learning_materials"
  add_foreign_key "material_views", "students"
  add_foreign_key "questions", "examinations"
  add_foreign_key "students", "classrooms"
  add_foreign_key "students", "users"
  add_foreign_key "subjects", "teachers"
  add_foreign_key "teachers", "users"
end
