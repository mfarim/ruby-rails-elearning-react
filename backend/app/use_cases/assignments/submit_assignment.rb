module Assignments
  class SubmitAssignment
    def initialize(assignment_repo: AssignmentRepository.new)
      @assignment_repo = assignment_repo
    end

    def call(assignment_id:, student:, file_path: nil, notes: nil)
      return UseCaseResult.failure("Student record not found", status: :forbidden) unless student

      assignment = @assignment_repo.find(assignment_id)
      sub = AssignmentSubmission.find_or_initialize_by(assignment: assignment, student: student)
      sub.file_path = file_path if file_path.present?
      sub.notes = notes if notes.present?
      sub.submitted_at = Time.current
      sub.status = Time.current > assignment.due_date ? 'late' : 'submitted'
      sub.save!

      UseCaseResult.success(sub)
    rescue ActiveRecord::RecordNotFound => e
      UseCaseResult.failure(e.message, status: :not_found)
    rescue ActiveRecord::RecordInvalid => e
      UseCaseResult.failure(e.message, status: :unprocessable_entity)
    end
  end
end
