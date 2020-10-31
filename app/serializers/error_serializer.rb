class ErrorSerializer
  include JSONAPI::Serializer

  def initialize(model)
    @model = model
  end

  def format_common_errors
    @model.errors.messages.map do |field, errors|
      errors.map do |error_message|
        {
          source: { pointer: "/data/attributes/#{field}" },
          detail: error_message
        }
      end
    end
  end

  def serializable_hash
    errors = format_common_errors
    { 'errors': errors.flatten }
  end
end
