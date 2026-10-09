module Api
  module V1
    class ExamRunnerController < BaseController
      def start
        require_student!
        return if performed?

        student = current_user.student
        return render_error("Student record not found") unless student

        exam = Examination.find(params[:id])
        attempt = ExamAttempt.find_or_initialize_by(examination: exam, student: student)

        if attempt.new_record? || (exam.allow_retry && attempt.status == 'completed')
          attempt.status = 'in_progress'
          attempt.started_at = Time.current
          attempt.remaining_seconds = exam.duration_minutes * 60
          attempt.violations_count = 0
          attempt.save!
        end

        questions = exam.questions.order(:id).to_a
        questions = questions.shuffle if exam.shuffle_questions

        # Fetch existing student answers if attempt was in progress
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

        json_response(data: response_data)
      end

      def answer
        require_student!
        return if performed?

        attempt = ExamAttempt.find(params[:attempt_id])
        return render_error("Attempt is already submitted") if attempt.status != 'in_progress'

        question = Question.find(params[:questionId])
        ans = ExamAnswer.find_or_initialize_by(exam_attempt: attempt, question: question)
        ans.student_answer = params[:answer].to_s
        ans.save!

        json_response(data: nil, message: "Answer saved")
      end

      def violation
        require_student!
        return if performed?

        attempt = ExamAttempt.find(params[:attempt_id])
        attempt.increment!(:violations_count)
        json_response(data: { violations: attempt.violations_count }, message: "Violation recorded")
      end

      def submit
        require_student!
        return if performed?

        attempt = ExamAttempt.find(params[:attempt_id])
        exam = attempt.examination

        # Calculate scores automatically
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

        json_response(data: {
          score: attempt.score,
          passed: attempt.passed,
          status: attempt.status,
          totalQuestions: questions.size,
          answeredCount: answers.size
        }, message: "Exam submitted successfully")
      end

      def grade_essay
        require_teacher!
        return if performed?

        attempt = ExamAttempt.find(params[:attempt_id])
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

        exam = Examination.find(params[:id])
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
    end
  end
end
