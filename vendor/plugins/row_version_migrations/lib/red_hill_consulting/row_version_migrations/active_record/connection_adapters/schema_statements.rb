module RedHillConsulting::RowVersionMigrations::ActiveRecord::ConnectionAdapters
  module SchemaStatements
    def self.included(base)
      base.module_eval do
        alias_method_chain :create_table, :row_version_migrations
      end
    end

    def create_table_with_row_version_migrations(name, options = {})
      create_table_without_row_version_migrations(name, options) do |table_defintion|
        yield table_defintion
        unless ActiveRecord::Schema.defining? || options[:row_version] == false
          table_defintion.column :created_at,   :datetime, :null => true
          table_defintion.column :created_by,   :integer,  :null => true,  :references=>:users, :on_delete=>:restrict, :on_update=>:cascade
          table_defintion.column :updated_at,   :datetime, :null => true
          table_defintion.column :updated_by,   :integer,  :null => true,:references=>:users, :on_delete=>:restrict, :on_update=>:cascade
          table_defintion.column :lock_version, :integer,  :null => false, :default => 0
        end
      end
      unless ActiveRecord::Schema.defining? || options[:row_version] == false
        add_index name, :created_at
        add_index name, :created_by
        add_index name, :updated_at
        add_index name, :updated_by
      end
    end
  end
end
