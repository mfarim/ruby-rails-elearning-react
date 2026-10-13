class BaseRepository
  attr_reader :model_class

  def initialize(model_class)
    @model_class = model_class
  end

  def all
    model_class.all
  end

  def find(id)
    model_class.find(id)
  end

  def find_by(conditions)
    model_class.find_by(conditions)
  end

  def create!(attributes)
    model_class.create!(attributes)
  end

  def update!(id, attributes)
    record = find(id)
    record.update!(attributes)
    record
  end

  def delete!(id)
    record = find(id)
    record.destroy!
  end

  def count
    model_class.count
  end
end
