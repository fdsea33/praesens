module RedHillConsulting::SchemaValidations::ActiveRecord
  module Base
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def self.extended(base)
        class << base
          alias_method_chain :allocate, :schema_validations
          alias_method_chain :new, :schema_validations
          alias_method_chain :belongs_to, :schema_validations
        end
      end

      def inherited(child)
        load_schema_validations unless self == ActiveRecord::Base
        super
      end

      def schema_validations(options = {})
        column_names = []
        if options[:only]
          column_names = options[:only]
          @schema_validations_column_include = true
        elsif options[:except]
          column_names = options[:except]
          @schema_validations_column_include = false
        end

        @schema_validations_column_names = Array(column_names).map(&:to_s)
      end

      def allocate_with_schema_validations
        load_schema_validations
        allocate_without_schema_validations
      end

      def new_with_schema_validations(*args, &block)
        load_schema_validations
        new_without_schema_validations(*args, &block)
      end

      def belongs_to_with_schema_validations(association_id, options = {})
        belongs_to_without_schema_validations(association_id, options)
        column = columns_hash[reflections[association_id.to_sym].primary_key_name.to_s]

        return unless validates?(column)

        # NOT NULL constraints
        module_eval(
          "validates_presence_of :#{column.name}, :on => :#{column.required_on}, :if => lambda { |record| record.#{association_id}.nil? }"
        ) if column.required_on

        # UNIQUE constraints
        validates_uniqueness_of column.name.to_sym, :scope => column.unique_scope.map(&:to_sym), :allow_nil => true if column.unique?
      end

      protected

      def load_schema_validations
        # Don't bother if: it's already been loaded; the class is abstract; not a base class; or the table doesn't exist
        return if @schema_validations_loaded || abstract_class? || !base_class? || name.blank? || !table_exists?
        @schema_validations_loaded = true

        content_columns.each do |column|
          next unless validates?(column)

          name = column.name.to_sym

          # Data-type validation
          if column.type == :integer
            validates_numericality_of name, :allow_nil => true, :only_integer => true
          elsif column.type == :date
            validates_each name do |model, attribute, value|
#              model.errors.add(attribute, "est invalide") if value.nil?
#              date_array = Date._strptime(value, ArkanisDevelopment::SimpleLocalization::Language[:dates, :date_formats, :parse])
#              if date_array.nil?
#                value = Date.civil(2007,07,07)
#                model.errors.add(attribute, "est sacrément invalide #{value}")
#              end
#              value = Date.new(date_array[:year], date_array[:mon], date_array[:mday]) rescue nil
            end
          elsif column.number?
            validates_numericality_of name, :allow_nil => true
          elsif column.text? && column.limit
            validates_length_of name, :allow_nil => true, :maximum => column.limit
          end

          # NOT NULL constraints
          if column.required_on
            # Work-around for a "feature" of the way validates_presence_of handles boolean fields
            # See http://dev.rubyonrails.org/ticket/5090 and http://dev.rubyonrails.org/ticket/3334
            if column.type == :boolean
              validates_inclusion_of name, :on => column.required_on, :in => [true, false], :message => ActiveRecord::Errors.default_error_messages[:blank]
            else
              validates_presence_of name, :on => column.required_on
            end
          end

          # UNIQUE constraints
          validates_uniqueness_of name, :scope => column.unique_scope.map(&:to_sym), :allow_nil => true, :case_sensitive => column.case_sensitive? if column.unique?
        end
      end

      private

      def validates?(column)
        column.name !~ /^(((created|updated)_(at|on))|position)$/ &&
          (@schema_validations_column_names.nil? || @schema_validations_column_names.include?(column.name) == @schema_validations_column_include)
      end
    end
  end
end
