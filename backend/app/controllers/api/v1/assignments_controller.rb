module Api
  module V1
    class AssignmentsController < BaseController
      before_action :set_assignment, only: [:show, :update, :destroy, :submit, :submissions, :discussions, :create_discussion]

      def index
        scope = assignment_repository.list_for_user(current_user)
        student = current_user.student
        submissions_map = student ? AssignmentSubmission.where(student_id: student.id).index_by(&:assignment_id) : {}

        data = scope.map { |a| assignment_payload(a, submissions_map[a.id]) }
        json_response(data: data)
      end

      def show
        student = current_user.student
        submission = student ? AssignmentSubmission.find_by(assignment: @assignment, student: student) : nil
        json_response(data: assignment_payload(@assignment, submission))
      end

      def create
        require_teacher!
        return if performed?

        teacher = current_user.teacher || Teacher.first
        assignment = assignment_repository.create!(
          teacher: teacher,
          subject_id: params[:subjectId],
          classroom_id: params[:classroomId],
          title: params[:title],
          description: params[:description],
          instructions: params[:instructions],
          max_score: params.fetch(:maxScore, 100),
          due_date: params[:dueDate],
          allow_late_submission: params.fetch(:allowLateSubmission, false),
          status: params.fetch(:status, 'published')
        )
        json_response(data: assignment_payload(assignment), message: "Assignment created successfully", status: :created)
      end

      def update
        require_teacher!
        return if performed?

        attrs = {
          subject_id: params[:subjectId],
          classroom_id: params[:classroomId],
          title: params[:title],
          description: params[:description],
          instructions: params[:instructions],
          max_score: params[:maxScore],
          due_date: params[:dueDate],
          allow_late_submission: params[:allowLateSubmission],
          status: params[:status]
        }.compact

        @assignment.update!(attrs)
        json_response(data: assignment_payload(@assignment), message: "Assignment updated successfully")
      end

      def destroy
        require_teacher!
        return if performed?

        assignment_repository.delete!(@assignment.id)
        json_response(data: nil, message: "Assignment deleted successfully")
      end

      def submit
        require_student!
        return if performed?

        result = submit_assignment_use_case.call(
          assignment_id: @assignment.id,
          student: current_user.student,
          file_path: params[:filePath],
          notes: params[:notes]
        )

        if result.success?
          json_response(data: submission_payload(result.data), message: "Assignment submitted successfully")
        else
          render_error(result.error, status: result.status, errors: result.errors)
        end
      end

      def submissions
        require_teacher!
        return if performed?

        subs = @assignment.submissions.includes(:student).order(submitted_at: :desc)
        data = subs.map { |s| submission_payload(s) }
        json_response(data: data)
      end

      def grade_submission
        require_teacher!
        return if performed?

        result = grade_assignment_use_case.call(
          submission_id: params[:submission_id],
          score: params[:score],
          feedback: params[:feedback]
        )

        if result.success?
          json_response(data: submission_payload(result.data), message: "Submission graded successfully")
        else
          render_error(result.error, status: result.status, errors: result.errors)
        end
      end

      def discussions
        all_comments = @assignment.discussions.includes(:user).order(created_at: :asc)
        top_level = all_comments.select { |c| c.parent_id.nil? }

        data = top_level.map { |c| discussion_payload(c, all_comments) }
        json_response(data: data)
      end

      def create_discussion
        comment = @assignment.discussions.create!(
          user: current_user,
          parent_id: params[:parentId],
          message: params[:message]
        )
        json_response(data: discussion_payload(comment, [comment]), message: "Comment posted", status: :created)
      end

      private

      def assignment_repository
        @assignment_repository ||= AssignmentRepository.new
      end

      def submit_assignment_use_case
        @submit_assignment_use_case ||= Assignments::SubmitAssignment.new(
          assignment_repo: assignment_repository
        )
      end

      def grade_assignment_use_case
        @grade_assignment_use_case ||= Assignments::GradeAssignment.new
      end

      def set_assignment
        @assignment = assignment_repository.find(params[:id])
      end

      def assignment_payload(a, submission = nil)
        {
          id: a.id,
          title: a.title,
          description: a.description,
          instructions: a.instructions,
          subjectId: a.subject_id,
          subjectName: a.subject&.name,
          classroomId: a.classroom_id,
          classroomName: a.classroom&.name,
          teacherId: a.teacher_id,
          teacherName: a.teacher&.name,
          maxScore: a.max_score,
          dueDate: a.due_date&.iso8601,
          allowLateSubmission: a.allow_late_submission,
          status: a.status,
          submissionsCount: a.submissions.count,
          submission: submission ? submission_payload(submission) : nil,
          createdAt: a.created_at&.iso8601
        }
      end

      def submission_payload(s)
        {
          id: s.id,
          assignmentId: s.assignment_id,
          studentId: s.student_id,
          studentName: s.student&.name,
          nis: s.student&.nis,
          filePath: s.file_path,
          notes: s.notes,
          submittedAt: s.submitted_at&.iso8601,
          score: s.score,
          feedback: s.feedback,
          status: s.status
        }
      end

      def discussion_payload(comment, all_comments)
        replies = all_comments.select { |c| c.parent_id == comment.id }
        {
          id: comment.id,
          userId: comment.user_id,
          userName: comment.user&.name,
          userRole: comment.user&.role,
          message: comment.message,
          createdAt: comment.created_at&.iso8601,
          replies: replies.map { |r| discussion_payload(r, all_comments) }
        }
      end
    end
  end
end
