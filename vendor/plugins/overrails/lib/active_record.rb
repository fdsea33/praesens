#require File.dirname(__FILE__) + '/../vendor/rails/activerecord/lib/active_record'

class ::ActiveRecord::Base
  class ObjectNotDestroyable < ActiveRecord::ActiveRecordError
  end

  def destroy_with_validation
    validate_on_destroy if self.respond_to? :validate_on_destroy
    unless errors.empty?
      errors.add_to_base("#{self.class.name.titleize} could not be deleted")
      raise ObjectNotDestroyable
    end
    destroy_without_validation
  end

  alias_method_chain :destroy, :validation
end
