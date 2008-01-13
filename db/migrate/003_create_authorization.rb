class CreateAuthorization < ActiveRecord::Migration
  def self.up
    # Role
    create_table :roles do |t|
			t.column :name,              :string, :null=>false
			t.column :admin,             :boolean, :null=>false, :default=>false
			t.column :company_id,        :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:restrict
    end
		add_index :roles, :name
		add_index :roles, :company_id

    # Privilege
    create_table :rights do |t|
      t.column :role_id,           :integer, :null=>false, :references=>:roles, :on_delete=>:cascade, :on_update=>:cascade
      t.column :active,            :boolean, :null=>false, :default=>true
      t.column :procedure_id,      :integer, :null=>false, :references=>:part_component_procedures, :on_delete=>:cascade, :on_update=>:cascade
      t.column :component_id,      :integer, :null=>false, :references=>:part_components, :on_delete=>:cascade, :on_update=>:cascade
      t.column :part_id,           :integer, :null=>false, :references=>:parts, :on_delete=>:cascade, :on_update=>:cascade
    end
    add_index :rights, [:role_id, :procedure_id], :unique=>true

		add_column :users, :role_id, :integer, :null=>false, :references=>:roles, :on_delete=>:restrict, :on_update=>:restrict
		add_index  :users, :role_id

    # Data
		part = Part.find_by_code(Part::ORGANISATION)
		component = PartComponent.create(:name=>"role", :part_id=>part.id)
    PartComponentProcedure.create(:name=>"select",:actions=>":index:list:show:", :component_id=>component.id)
    PartComponentProcedure.create(:name=>"insert",:actions=>":new:create:",      :component_id=>component.id)
    PartComponentProcedure.create(:name=>"update",:actions=>":edit:update:manage_privileges:", :component_id=>component.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"delete",:actions=>":destroy:",         :component_id=>component.id, :contextual=>true)

  end

  def self.down
    drop_table :rights
		remove_column :users, :role_id
    drop_table :roles
  end
end
