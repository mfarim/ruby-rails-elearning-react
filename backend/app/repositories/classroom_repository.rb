class ClassroomRepository < BaseRepository
  def initialize
    super(Classroom)
  end

  def list_with_homeroom
    model_class.includes(:homeroom_teacher).order(:level, :name)
  end
end
