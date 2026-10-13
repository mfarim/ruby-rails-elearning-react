class ExamAttemptRepository < BaseRepository
  def initialize
    super(ExamAttempt)
  end

  def find_or_initialize_for(exam, student)
    model_class.find_or_initialize_by(examination: exam, student: student)
  end

  def attempts_map_for_student(student_id)
    return {} unless student_id

    model_class.where(student_id: student_id).index_by(&:examination_id)
  end
end
