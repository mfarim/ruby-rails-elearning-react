class CreateElearningSchema < ActiveRecord::Migration[8.0]
  def change
    # 1. Users
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, default: 'ROLE_STUDENT', null: false
      t.boolean :active, default: true, null: false
      t.bigint :impersonated_by_id
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :role

    # 2. Teachers
    create_table :teachers do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :nip, null: false
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.text :address
      t.string :photo
      t.boolean :active, default: true, null: false
      t.timestamps
    end
    add_index :teachers, :nip, unique: true

    # 3. Classrooms
    create_table :classrooms do |t|
      t.string :name, null: false
      t.integer :level, default: 10, null: false
      t.integer :capacity, default: 36, null: false
      t.string :academic_year, default: '2025/2026', null: false
      t.references :homeroom_teacher, foreign_key: { to_table: :teachers }
      t.timestamps
    end
    add_index :classrooms, :name

    # 4. Students
    create_table :students do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :classroom, foreign_key: true
      t.string :nis, null: false
      t.string :nisn
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :gender, default: 'M', null: false
      t.date :birth_date
      t.text :address
      t.string :photo
      t.boolean :active, default: true, null: false
      t.timestamps
    end
    add_index :students, :nis, unique: true

    # 5. Subjects
    create_table :subjects do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.references :teacher, foreign_key: true
      t.integer :credits, default: 3, null: false
      t.timestamps
    end
    add_index :subjects, :code, unique: true

    # 6. Announcements
    create_table :announcements do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :target, default: 'all', null: false
      t.boolean :published, default: true, null: false
      t.timestamps
    end

    # 7. Learning Materials
    create_table :learning_materials do |t|
      t.references :teacher, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.references :classroom, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :material_type, default: 'document', null: false
      t.text :content
      t.string :file_url
      t.string :file_path
      t.boolean :published, default: true, null: false
      t.integer :total_views, default: 0, null: false
      t.timestamps
    end

    # 8. Material Views
    create_table :material_views do |t|
      t.references :learning_material, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.datetime :viewed_at, null: false
      t.timestamps
    end
    add_index :material_views, [:learning_material_id, :student_id], unique: true

    # 9. Assignments
    create_table :assignments do |t|
      t.references :teacher, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.references :classroom, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.text :instructions
      t.integer :max_score, default: 100, null: false
      t.datetime :due_date, null: false
      t.boolean :allow_late_submission, default: false, null: false
      t.string :status, default: 'published', null: false
      t.timestamps
    end

    # 10. Assignment Submissions
    create_table :assignment_submissions do |t|
      t.references :assignment, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.string :file_path
      t.text :notes
      t.decimal :score, precision: 5, scale: 2
      t.text :feedback
      t.string :status, default: 'submitted', null: false
      t.datetime :submitted_at, null: false
      t.datetime :graded_at
      t.timestamps
    end
    add_index :assignment_submissions, [:assignment_id, :student_id], unique: true

    # 11. Assignment Discussions
    create_table :assignment_discussions do |t|
      t.references :assignment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :assignment_discussions }
      t.text :message, null: false
      t.timestamps
    end

    # 12. Examinations
    create_table :examinations do |t|
      t.references :teacher, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.references :classroom, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :exam_type, default: 'quiz', null: false
      t.integer :duration_minutes, default: 60, null: false
      t.decimal :passing_score, precision: 5, scale: 2, default: 75.0, null: false
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :shuffle_questions, default: false, null: false
      t.boolean :shuffle_options, default: false, null: false
      t.boolean :show_result, default: true, null: false
      t.boolean :allow_retry, default: false, null: false
      t.string :status, default: 'draft', null: false
      t.timestamps
    end

    # 13. Questions
    create_table :questions do |t|
      t.references :examination, null: false, foreign_key: true
      t.text :question_text, null: false
      t.string :question_type, default: 'multiple_choice', null: false
      t.jsonb :options, default: []
      t.integer :points, default: 10, null: false
      t.string :difficulty, default: 'medium', null: false
      t.string :correct_answer
      t.text :explanation
      t.string :image_path
      t.string :audio_path
      t.timestamps
    end

    # 14. Exam Attempts
    create_table :exam_attempts do |t|
      t.references :examination, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.string :status, default: 'in_progress', null: false
      t.decimal :score, precision: 5, scale: 2
      t.boolean :passed
      t.integer :violations_count, default: 0, null: false
      t.datetime :started_at, null: false
      t.datetime :finished_at
      t.integer :remaining_seconds
      t.timestamps
    end

    # 15. Exam Answers
    create_table :exam_answers do |t|
      t.references :exam_attempt, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.text :student_answer
      t.boolean :is_correct
      t.decimal :points_awarded, precision: 5, scale: 2, default: 0.0
      t.datetime :graded_at
      t.timestamps
    end
    add_index :exam_answers, [:exam_attempt_id, :question_id], unique: true
  end
end
