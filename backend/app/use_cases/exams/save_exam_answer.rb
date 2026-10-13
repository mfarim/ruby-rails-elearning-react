module Exams
  class SaveExamAnswer
    def initialize(attempt_repo: ExamAttemptRepository.new)
      @attempt_repo = attempt_repo
    end

    def call(attempt_id:, question_id:, answer:)
      attempt = @attempt_repo.find(attempt_id)
      if attempt.status != 'in_progress'
        return UseCaseResult.failure("Attempt is already submitted or inactive", status: :bad_request)
      end

      question = Question.find(question_id)
      ans = ExamAnswer.find_or_initialize_by(exam_attempt: attempt, question: question)
      ans.student_answer = answer.to_s
      ans.save!

      UseCaseResult.success(nil)
    rescue ActiveRecord::RecordNotFound => e
      UseCaseResult.failure(e.message, status: :not_found)
    rescue ActiveRecord::RecordInvalid => e
      UseCaseResult.failure(e.message, status: :unprocessable_entity)
    end
  end
end
