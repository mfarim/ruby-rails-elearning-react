module Exams
  class StartExamAttempt
    def initialize(
      exam_repo: ExaminationRepository.new,
      attempt_repo: ExamAttemptRepository.new
    )
      @exam_repo = exam_repo
      @attempt_repo = attempt_repo
    end

    def call(exam_id:, student:)
      return UseCaseResult.failure("Student record not found", status: :forbidden) unless student

      exam = @exam_repo.find(exam_id)
      attempt = @attempt_repo.find_or_initialize_for(exam, student)

      if attempt.new_record? || (exam.allow_retry && attempt.status == 'completed')
        attempt.status = 'in_progress'
        attempt.started_at = Time.current
        attempt.remaining_seconds = exam.duration_minutes * 60
        attempt.violations_count = 0
        attempt.save!
      end

      questions = exam.questions.order(:id).to_a
      questions = questions.shuffle if exam.shuffle_questions

      existing_answers = ExamAnswer.where(exam_attempt: attempt).index_by(&:question_id)

      questions_payload = questions.map do |q|
        options = q.options || []
        options = options.shuffle if exam.shuffle_options
        {
          id: q.id,
          examinationId: q.examination_id,
          questionText: q.question_text,
          questionType: q.question_type,
          options: options,
          points: q.points,
          difficulty: q.difficulty,
          studentAnswer: existing_answers[q.id]&.student_answer,
          imagePath: q.image_path,
          audioPath: q.audio_path
        }
      end

      elapsed = (Time.current - attempt.started_at).to_i
      remaining = [exam.duration_minutes * 60 - elapsed, 0].max

      response_data = {
        attemptId: attempt.id,
        examId: exam.id,
        examTitle: exam.title,
        durationMinutes: exam.duration_minutes,
        remainingSeconds: remaining,
        startedAt: attempt.started_at.iso8601,
        totalQuestions: questions.size,
        questions: questions_payload
      }

      UseCaseResult.success(response_data)
    rescue ActiveRecord::RecordNotFound => e
      UseCaseResult.failure(e.message, status: :not_found)
    end
  end
end
