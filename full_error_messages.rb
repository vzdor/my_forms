module FullErrorMessages
  def full_error_messages
    messages = errors.messages.dup
    errors.messages.each do |attribute, |
      if respond_to?(attribute)
        model = send(attribute)
        if model.kind_of?(Array)
          messages[attribute] = model.map(&:full_error_messages)
        elsif model.respond_to?(:full_error_messages)
          messages[attribute] = model.full_error_messages
        end
      end
    end
    messages
  end

end
