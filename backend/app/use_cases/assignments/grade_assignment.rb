module Assignments
  class GradeAssignment
    def call(submission_id:, score:, feedback: nil)
      sub = AssignmentSubmission.find(submission_id)
      sub.update!(
        score: score,
        feedback: feedback,
        status: 'graded'
      )

      UseCaseResult.success(sub)
    rescue ActiveRecord::RecordNotFound => e
      UseCaseResult.failure(e.message, status: :not_found)
    rescue ActiveRecord::RecordInvalid => e
      UseCaseResult.failure(e.message, status: :unprocessable_entity)
    end
  end
end
