module Api
  module V1
    class AssignmentsController < BaseController
      before_action :set_assignment, only: [:show, :update, :destroy, :submit, :submissions, :discussions, :create_discussion]

      def index
        scope = Assignment.includes(:teacher, :subject, :classroom).order(due_date: :asc)
        student = current_user.student

        if current_user.teacher?
          scope = scope.where(teacher_id: current_user.teacher&.id)
        elsif student
          scope = scope.where(classroom_id: student.classroom_id, status: 'published')
        end

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
        assignment = Assignment.create!(
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

        @assignment.destroy!
        json_response(data: nil, message: "Assignment deleted successfully")
      end

      def submit
        require_student!
        return if performed?

        student = current_user.student
        return render_error("Student record not found") unless student

        sub = AssignmentSubmission.find_or_initialize_by(assignment: @assignment, student: student)
        sub.file_path = params[:filePath] if params[:filePath].present?
        sub.notes = params[:notes] if params[:notes].present?
        sub.submitted_at = Time.current
        sub.status = Time.current > @assignment.due_date ? 'late' : 'submitted'
        sub.save!

        json_response(data: submission_payload(sub), message: "Assignment submitted successfully")
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

        sub = AssignmentSubmission.find(params[:submission_id])
        sub.update!(
          score: params[:score],
          feedback: params[:feedback],
          graded_at: Time.current,
          status: 'graded'
        )
        json_response(data: submission_payload(sub), message: "Submission graded successfully")
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

      def set_assignment
        @assignment = Assignment.find(params[:id])
      end

      def assignment_payload(a, submission = nil)
        {
          id: a.id,
          teacherId: a.teacher_id,
          teacherName: a.teacher&.name,
          subjectId: a.subject_id,
          subjectName: a.subject&.name,
          classroomId: a.classroom_id,
          classroomName: a.classroom&.name,
          title: a.title,
          description: a.description,
          instructions: a.instructions,
          maxScore: a.max_score,
          dueDate: a.due_date&.iso8601,
          allowLateSubmission: a.allow_late_submission,
          status: a.status,
          createdAt: a.created_at&.iso8601,
          hasSubmitted: submission.present?,
          studentScore: submission&.score,
          studentSubmissionStatus: submission&.status,
          studentSubmittedAt: submission&.submitted_at&.iso8601
        }
      end

      def submission_payload(s)
        {
          id: s.id,
          assignmentId: s.assignment_id,
          studentId: s.student_id,
          studentName: s.student.name,
          studentNis: s.student.nis,
          filePath: s.file_path,
          notes: s.notes,
          score: s.score,
          feedback: s.feedback,
          status: s.status,
          submittedAt: s.submitted_at&.iso8601,
          gradedAt: s.graded_at&.iso8601
        }
      end

      def discussion_payload(c, all_comments)
        replies = all_comments.select { |r| r.parent_id == c.id }.map { |r| discussion_payload(r, all_comments) }
        {
          id: c.id,
          assignmentId: c.assignment_id,
          userId: c.user_id,
          userName: c.user.name,
          userRole: c.user.role,
          message: c.message,
          createdAt: c.created_at&.iso8601,
          replies: replies
        }
      end
    end
  end
end
