module Api
  module V1
    class ExamRunnerController < BaseController
      def start
        require_student!
        return if performed?

        result = start_exam_attempt_use_case.call(
          exam_id: params[:id],
          student: current_user.student
        )
        handle_result(result)
      end

      def answer
        require_student!
        return if performed?

        result = save_exam_answer_use_case.call(
          attempt_id: params[:attempt_id],
          question_id: params[:questionId],
          answer: params[:answer]
        )
        handle_result(result, message: "Answer saved")
      end

      def violation
        require_student!
        return if performed?

        attempt = exam_attempt_repository.find(params[:attempt_id])
        attempt.increment!(:violations_count)
        json_response(data: { violations: attempt.violations_count }, message: "Violation recorded")
      end

      def submit
        require_student!
        return if performed?

        result = submit_exam_attempt_use_case.call(attempt_id: params[:attempt_id])
        handle_result(result, message: "Exam submitted successfully")
      end

      def grade_essay
        require_teacher!
        return if performed?

        attempt = exam_attempt_repository.find(params[:attempt_id])
        ans = attempt.exam_answers.find(params[:answer_id])
        points = params[:pointsAwarded].to_f

        ans.update!(
          points_awarded: points,
          is_correct: params[:isCorrect],
          graded_at: Time.current
        )

        # Recalculate attempt score
        total_points = attempt.examination.questions.sum(:points)
        total_earned = attempt.exam_answers.sum(:points_awarded)
        score_pct = total_points > 0 ? (total_earned / total_points * 100.0).round(2) : 0.0

        all_graded = !attempt.exam_answers.joins(:question).where(questions: { question_type: 'essay' }, points_awarded: nil).exists?
        attempt.update!(
          score: score_pct,
          passed: score_pct >= attempt.examination.passing_score,
          status: all_graded ? 'completed' : 'needs_grading'
        )

        json_response(data: nil, message: "Essay graded successfully")
      end

      def monitor
        require_teacher!
        return if performed?

        exam = examination_repository.find(params[:id])
        attempts = exam.exam_attempts.includes(student: :classroom).order(started_at: :desc)
        total_q = exam.questions.count

        data = attempts.map do |att|
          {
            attemptId: att.id,
            studentId: att.student_id,
            studentName: att.student.name,
            nis: att.student.nis,
            status: att.status,
            score: att.score,
            passed: att.passed,
            violations: att.violations_count,
            answeredCount: att.exam_answers.count,
            totalQuestions: total_q,
            startedAt: att.started_at&.iso8601,
            finishedAt: att.finished_at&.iso8601
          }
        end

        json_response(data: data)
      end

      private

      def examination_repository
        @examination_repository ||= ExaminationRepository.new
      end

      def exam_attempt_repository
        @exam_attempt_repository ||= ExamAttemptRepository.new
      end

      def start_exam_attempt_use_case
        @start_exam_attempt_use_case ||= Exams::StartExamAttempt.new(
          exam_repo: examination_repository,
          attempt_repo: exam_attempt_repository
        )
      end

      def save_exam_answer_use_case
        @save_exam_answer_use_case ||= Exams::SaveExamAnswer.new(
          attempt_repo: exam_attempt_repository
        )
      end

      def submit_exam_attempt_use_case
        @submit_exam_attempt_use_case ||= Exams::SubmitExamAttempt.new(
          attempt_repo: exam_attempt_repository
        )
      end
    end
  end
end
