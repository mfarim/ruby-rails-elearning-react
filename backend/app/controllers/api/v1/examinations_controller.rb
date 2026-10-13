module Api
  module V1
    class ExaminationsController < BaseController
      before_action :set_exam, only: [:show, :update, :destroy, :update_status, :questions, :create_question, :import_questions_excel]

      def index
        scope = examination_repository.list_for_user(current_user)
        student = current_user.student
        attempts_map = exam_attempt_repository.attempts_map_for_student(student&.id)

        data = scope.map { |e| exam_payload(e, attempts_map[e.id]) }
        json_response(data: data)
      end

      def show
        student = current_user.student
        attempt = student ? exam_attempt_repository.find_by(examination: @exam, student: student) : nil
        json_response(data: exam_payload(@exam, attempt))
      end

      def create
        require_teacher!
        return if performed?

        teacher = current_user.teacher || Teacher.first
        exam = Examination.create!(
          teacher: teacher,
          subject_id: params[:subjectId],
          classroom_id: params[:classroomId],
          title: params[:title],
          description: params[:description],
          exam_type: params[:type] || 'quiz',
          duration_minutes: params.fetch(:durationMinutes, 60),
          passing_score: params.fetch(:passingScore, 75.0),
          start_at: params[:startAt],
          end_at: params[:endAt],
          shuffle_questions: params.fetch(:shuffleQuestions, false),
          shuffle_options: params.fetch(:shuffleOptions, false),
          show_result: params.fetch(:showResult, true),
          allow_retry: params.fetch(:allowRetry, false),
          status: params.fetch(:status, 'draft')
        )
        json_response(data: exam_payload(exam), message: "Exam created successfully", status: :created)
      end

      def update
        require_teacher!
        return if performed?

        attrs = {
          subject_id: params[:subjectId],
          classroom_id: params[:classroomId],
          title: params[:title],
          description: params[:description],
          exam_type: params[:type],
          duration_minutes: params[:durationMinutes],
          passing_score: params[:passingScore],
          start_at: params[:startAt],
          end_at: params[:endAt],
          shuffle_questions: params[:shuffleQuestions],
          shuffle_options: params[:shuffleOptions],
          show_result: params[:showResult],
          allow_retry: params[:allowRetry],
          status: params[:status]
        }.compact

        @exam.update!(attrs)
        json_response(data: exam_payload(@exam), message: "Exam updated successfully")
      end

      def destroy
        require_teacher!
        return if performed?

        @exam.destroy!
        json_response(data: nil, message: "Exam deleted successfully")
      end

      def update_status
        require_teacher!
        return if performed?

        @exam.update!(status: params[:status])
        json_response(data: exam_payload(@exam), message: "Exam status updated to #{params[:status]}")
      end

      def questions
        questions = @exam.questions.order(:id)
        data = questions.map { |q| question_payload(q) }
        json_response(data: data)
      end

      def create_question
        require_teacher!
        return if performed?

        opts = params[:options] || []
        opts = JSON.parse(opts) if opts.is_a?(String)

        question = @exam.questions.create!(
          question_text: params[:questionText],
          question_type: params[:questionType] || 'multiple_choice',
          options: opts,
          points: params.fetch(:points, 10),
          difficulty: params.fetch(:difficulty, 'medium'),
          correct_answer: params[:correctAnswer],
          explanation: params[:explanation],
          image_path: params[:imagePath],
          audio_path: params[:audioPath]
        )
        json_response(data: question_payload(question), message: "Question added", status: :created)
      end

      def update_question
        require_teacher!
        return if performed?

        question = @exam.questions.find(params[:question_id])
        opts = params[:options]
        opts = JSON.parse(opts) if opts.is_a?(String)

        attrs = {
          question_text: params[:questionText],
          question_type: params[:questionType],
          options: opts,
          points: params[:points],
          difficulty: params[:difficulty],
          correct_answer: params[:correctAnswer],
          explanation: params[:explanation],
          image_path: params[:imagePath],
          audio_path: params[:audioPath]
        }.compact

        question.update!(attrs)
        json_response(data: question_payload(question), message: "Question updated")
      end

      def destroy_question
        require_teacher!
        return if performed?

        question = @exam.questions.find(params[:question_id])
        question.destroy!
        json_response(data: nil, message: "Question deleted")
      end

      def import_questions_excel
        require_teacher!
        return if performed?

        file = params[:file]
        return render_error("Please upload an Excel file") unless file.present?

        rows = ExcelService.parse_questions(file.path)
        count = 0

        Question.transaction do
          rows.each do |row|
            options = []
            ['a', 'b', 'c', 'd', 'e'].each do |opt_key|
              val = row["option_#{opt_key}"]
              options << val if val.present?
            end

            @exam.questions.create!(
              question_text: row['question_text'],
              question_type: row['question_type'].presence || (options.any? ? 'multiple_choice' : 'essay'),
              options: options,
              points: row['points'].presence || 10,
              difficulty: row['difficulty'].presence || 'medium',
              correct_answer: row['correct_answer']&.to_s,
              explanation: row['explanation']
            )
            count += 1
          end
        end

        json_response(data: { count: count }, message: "Imported #{count} questions successfully")
      end

      private

      def examination_repository
        @examination_repository ||= ExaminationRepository.new
      end

      def exam_attempt_repository
        @exam_attempt_repository ||= ExamAttemptRepository.new
      end

      def set_exam
        @exam = examination_repository.find(params[:id])
      end

      def exam_payload(e, attempt = nil)
        {
          id: e.id,
          teacherId: e.teacher_id,
          teacherName: e.teacher&.name,
          subjectId: e.subject_id,
          subjectName: e.subject&.name,
          classroomId: e.classroom_id,
          classroomName: e.classroom&.name,
          title: e.title,
          description: e.description,
          type: e.exam_type,
          durationMinutes: e.duration_minutes,
          passingScore: e.passing_score,
          startAt: e.start_at&.iso8601,
          endAt: e.end_at&.iso8601,
          examDate: e.start_at&.strftime('%Y-%m-%d'),
          totalQuestions: e.questions.size,
          shuffleQuestions: e.shuffle_questions,
          shuffleOptions: e.shuffle_options,
          showResult: e.show_result,
          allowRetry: e.allow_retry,
          status: e.status,
          createdAt: e.created_at&.iso8601,
          studentAttemptStatus: attempt&.status,
          studentScore: attempt&.score,
          studentPassed: attempt&.passed,
          currentAttemptId: attempt&.id
        }
      end

      def question_payload(q)
        {
          id: q.id,
          examinationId: q.examination_id,
          questionText: q.question_text,
          questionType: q.question_type,
          options: q.options || [],
          points: q.points,
          difficulty: q.difficulty,
          correctAnswer: q.correct_answer,
          explanation: q.explanation,
          imagePath: q.image_path,
          audioPath: q.audio_path
        }
      end
    end
  end
end
