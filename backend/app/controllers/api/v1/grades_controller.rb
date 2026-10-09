module Api
  module V1
    class GradesController < BaseController
      def index
        require_student!
        return if performed?

        student = current_user.student
        return render_error("Student record not found") unless student

        attempts = student.exam_attempts.includes(examination: :subject).where(status: 'completed')
        submissions = student.assignment_submissions.includes(assignment: :subject).where(status: 'graded')

        subjects = Subject.all.map do |subj|
          subj_attempts = attempts.select { |a| a.examination.subject_id == subj.id }
          subj_submissions = submissions.select { |s| s.assignment.subject_id == subj.id }

          avg_exam = subj_attempts.any? ? (subj_attempts.sum(&:score) / subj_attempts.size).round(2) : 0.0
          passed_exams = subj_attempts.count(&:passed)
          avg_assignment = subj_submissions.any? ? (subj_submissions.sum(&:score) / subj_submissions.size).round(2) : 0.0

          overall = ((avg_exam * 0.6) + (avg_assignment * 0.4)).round(2)

          {
            subjectId: subj.id,
            subjectName: subj.name,
            subjectCode: subj.code,
            credits: subj.credits,
            avgExamScore: avg_exam,
            totalExams: subj_attempts.size,
            passedExams: passed_exams,
            avgAssignmentScore: avg_assignment,
            totalAssignments: subj_submissions.size,
            overallScore: overall
          }
        end

        overall_gpa = subjects.any? ? (subjects.sum { |s| s[:overallScore] } / subjects.size / 25.0).round(2) : 0.0

        data = {
          studentId: student.id,
          studentName: student.name,
          nis: student.nis,
          classroomName: student.classroom&.name || "-",
          overallGpa: [overall_gpa, 4.0].min,
          totalCompletedExams: attempts.size,
          totalPassedExams: attempts.count(&:passed),
          subjects: subjects
        }

        json_response(data: data)
      end
    end
  end
end
