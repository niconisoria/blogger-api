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

  def check_relationship_error(child)
    child.errors.messages.map do |field, errors|
      errors.map do |error_message|
        {
          source: { pointer: "/data/attributes/#{child.model_name.plural}[#{index}].#{field}" },
          detail: error_message
        }
      end
    end
  end

  def format_relationship_errors
    errors = []
    @model.class.reflect_on_all_associations.each do |relationship|
      relationship = @model.send(relationship.name)
      if relationship.respond_to?(:each)
        relationship.each do |child|
          errors << check_relationship_error(child)
        end
      else
        errors << check_relationship_error(relationship)
      end
    end
    errors
  end

  def serializable_hash
    errors = format_common_errors
    errors << format_relationship_errors
    { 'errors': errors.flatten }
  end
end
