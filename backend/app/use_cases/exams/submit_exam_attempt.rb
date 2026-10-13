module Exams
  class SubmitExamAttempt
    def initialize(attempt_repo: ExamAttemptRepository.new)
      @attempt_repo = attempt_repo
    end

    def call(attempt_id:)
      attempt = @attempt_repo.find(attempt_id)
      exam = attempt.examination

      questions = exam.questions.index_by(&:id)
      answers = attempt.exam_answers.includes(:question)

      total_points = questions.values.sum(&:points)
      earned_points = 0.0
      has_essay = false

      answers.each do |ans|
        q = ans.question
        next unless q

        if q.question_type == 'multiple_choice' || q.question_type == 'true_false'
          is_correct = ans.student_answer.to_s.strip.downcase == q.correct_answer.to_s.strip.downcase
          ans.update!(
            is_correct: is_correct,
            points_awarded: is_correct ? q.points : 0.0,
            graded_at: Time.current
          )
          earned_points += q.points if is_correct
        elsif q.question_type == 'essay'
          has_essay = true
        end
      end

      score_pct = total_points > 0 ? (earned_points / total_points * 100.0).round(2) : 0.0
      passed = score_pct >= exam.passing_score

      attempt.update!(
        score: score_pct,
        passed: passed,
        finished_at: Time.current,
        status: has_essay ? 'needs_grading' : 'completed',
        remaining_seconds: 0
      )

      payload = {
        score: attempt.score,
        passed: attempt.passed,
        status: attempt.status,
        totalQuestions: questions.size,
        answeredCount: answers.size
      }

      UseCaseResult.success(payload)
    rescue ActiveRecord::RecordNotFound => e
      UseCaseResult.failure(e.message, status: :not_found)
    end
  end
end
