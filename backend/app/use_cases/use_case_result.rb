class UseCaseResult
  attr_reader :data, :error, :errors, :status

  def initialize(success:, data: nil, error: nil, errors: nil, status: :ok)
    @success = success
    @data = data
    @error = error
    @errors = errors
    @status = status
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  def self.success(data = nil, status: :ok)
    new(success: true, data: data, status: status)
  end

  def self.failure(error, status: :bad_request, errors: nil)
    new(success: false, error: error, errors: errors, status: status)
  end
end
