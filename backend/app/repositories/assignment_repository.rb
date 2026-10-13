class AssignmentRepository < BaseRepository
  def initialize
    super(Assignment)
  end

  def list_for_user(user)
    scope = model_class.includes(:teacher, :subject, :classroom).order(due_date: :asc)
    student = user.student

    if user.teacher?
      scope.where(teacher_id: user.teacher&.id)
    elsif student
      scope.where(classroom_id: student.classroom_id, status: 'published')
    else
      scope
    end
  end
end
