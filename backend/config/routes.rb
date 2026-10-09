Rails.application.routes.draw do
  get '/health', to: proc { [200, { 'Content-Type' => 'application/json' }, [{ status: 'healthy', app: 'ruby-rails-elearning', timestamp: Time.current.iso8601 }.to_json]] }

  namespace :api do
    namespace :v1 do
      # Authentication & Impersonation
      post 'auth/login', to: 'auth#login'
      post 'auth/register', to: 'auth#register'
      get 'auth/me', to: 'auth#me'
      post 'admin/impersonate/:user_id', to: 'auth#impersonate'
      post 'admin/stop-impersonate', to: 'auth#stop_impersonate'

      # Academic Management
      resources :classrooms
      resources :subjects

      # User Management
      resources :teachers
      resources :students do
        collection do
          get 'exam-cards', to: 'students#exam_cards'
          post 'import-excel', to: 'students#import_excel'
        end
      end

      # Announcements
      resources :announcements

      # Learning Materials
      resources :materials, controller: 'learning_materials' do
        member do
          post 'views', to: 'learning_materials#record_view'
          get 'viewers', to: 'learning_materials#viewers'
        end
      end

      # Assignments & Discussions
      resources :assignments do
        member do
          post 'submit', to: 'assignments#submit'
          get 'submissions', to: 'assignments#submissions'
          get 'discussions', to: 'assignments#discussions'
          post 'discussions', to: 'assignments#create_discussion'
        end
        collection do
          post 'submissions/:submission_id/grade', to: 'assignments#grade_submission'
        end
      end

      # Examination Management & CBT Runner
      resources :exams, controller: 'examinations' do
        member do
          patch 'status', to: 'examinations#update_status'
          get 'questions', to: 'examinations#questions'
          post 'questions', to: 'examinations#create_question'
          put 'questions/:question_id', to: 'examinations#update_question'
          delete 'questions/:question_id', to: 'examinations#destroy_question'
          post 'questions/import-excel', to: 'examinations#import_questions_excel'
          post 'start', to: 'exam_runner#start'
          get 'monitor', to: 'exam_runner#monitor'
        end
      end

      # Exam Runner Endpoints
      scope :exams do
        post 'attempts/:attempt_id/answer', to: 'exam_runner#answer'
        post 'attempts/:attempt_id/violation', to: 'exam_runner#violation'
        post 'attempts/:attempt_id/submit', to: 'exam_runner#submit'
        post 'attempts/:attempt_id/answers/:answer_id/grade-essay', to: 'exam_runner#grade_essay'
      end

      # Student Grades & Reports
      get 'student/grades', to: 'grades#index'

      # File Management
      post 'files/upload', to: 'files#upload'
      get 'files/*file_path', to: 'files#show', format: false
    end
  end
end
