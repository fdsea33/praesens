class CreateApplication < ActiveRecord::Migration
  def self.up
    # Session
    create_table :sessions, :row_version=>false do |t|
      t.column :session_id,       :string, :references=>nil
      t.column :data,             :text
      t.column :updated_at,       :datetime
    end
    add_index :sessions, :session_id
    add_index :sessions, :updated_at

    # User
    create_table :users do |t|
			t.column :name,            :string,  :null=>false, :limit=>32
			t.column :hashed_password, :string,  :null=>false
			t.column :salt,            :string,  :null=>false
			t.column :locked,          :boolean, :null=>false, :default=>false
			t.column :email,           :string
    end
		add_index :users, :name, :unique=>true
		add_index :users, :email

    # Company
    create_table :companies do |t|
			t.column :name,       :string,   :null=>false
			t.column :code,       :string,   :null=>false, :limit=>8
			t.column :admin,      :boolean,  :null=>false, :default=>false
      t.column :siren,      :string,   :null=>false, :default=>"000000000", :limit=>9
    end
		add_index :companies, :name, :unique=>true
		add_index :companies, :code, :unique=>true

    # User supp
    add_column :users, :company_id, :integer, :null=>false, :references=>:companies, :on_delete=>:cascade, :on_update=>:restrict
		add_index  :users, :company_id

    # Part
    create_table :parts do |t|
			t.column :name,              :string,  :null=>false
			t.column :code,              :string,  :null=>false, :limit=>8
			t.column :active,            :boolean, :null=>false, :default=>true
			t.column :image_url,         :string
      t.column :position,          :integer
    end
		add_index :parts, :name, :unique=>true
		add_index :parts, :code, :unique=>true
		
		# PartComponent
    create_table :part_components do |t|
			t.column :name,              :string,  :null=>false
			t.column :part_id,           :integer, :null=>false, :references=>:parts, :on_delete=>:cascade, :on_update=>:restrict
      t.column :position,          :integer
    end
		add_index :part_components, [:name, :part_id], :unique=>true
		add_index :part_components, :part_id

    # PartComponentProcedure
    create_table :part_component_procedures do |t|
			t.column :name,              :string,  :null=>false
      t.column :controller_path,   :string,  :null=>false, :default=>"[NoControllerPath]"
      t.column :contextual,        :boolean, :null=>false, :default=>false
      t.column :actions,           :text,    :null=>false, :default=>":"  
			t.column :component_id,      :integer, :null=>false, :references=>:part_components, :on_delete=>:cascade, :on_update=>:restrict
			t.column :parent_id,         :integer, :references=>:part_component_procedures, :on_delete=>:cascade, :on_update=>:cascade
      t.column :position,          :integer
    end
		add_index :part_component_procedures, [:name, :component_id], :unique=>true
		add_index :part_component_procedures, :component_id
		add_index :part_component_procedures, :actions
		add_index :part_component_procedures, :contextual
		add_index :part_component_procedures, :parent_id

    # Data
		part = Part.create(:name=>"administration", :code=>Part::ADMINISTRATION, :image_url=>"part-administration.png")
    component = PartComponent.create(:name=>"application", :part_id=>part.id)
    PartComponentProcedure.create(:name=>"select",   :actions=>":index:list:show:", :component_id=>component.id)
    PartComponentProcedure.create(:name=>"activate", :actions=>":activate:deactivate:", :component_id=>component.id, :contextual=>true)

		component = PartComponent.create(:name=>"company", :part_id=>part.id)
    PartComponentProcedure.create(:name=>"select",:actions=>":index:list:show:",:component_id=>component.id)
    PartComponentProcedure.create(:name=>"insert",:actions=>":new:create:",:component_id=>component.id)
    PartComponentProcedure.create(:name=>"update",:actions=>":edit:update:",:component_id=>component.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"delete",:actions=>":destroy:",:component_id=>component.id, :contextual=>true)

		part = Part.create(:name=>"organisation",:code=>Part::ORGANISATION, :image_url=>"part-organisation.png")
		component = PartComponent.create(:name=>"company", :part_id=>part.id)
    PartComponentProcedure.create(:name=>"select",:actions=>":index:list:show:",:component_id=>component.id)
    PartComponentProcedure.create(:name=>"update",:actions=>":edit:update:",:component_id=>component.id, :contextual=>true)
		component = PartComponent.create(:name=>"user", :part_id=>part.id)
    PartComponentProcedure.create(:name=>"select",:actions=>":index:list:show:",:component_id=>component.id)
    PartComponentProcedure.create(:name=>"insert",:actions=>":new:create:",:component_id=>component.id)
    PartComponentProcedure.create(:name=>"update",:actions=>":edit:update:",:component_id=>component.id, :contextual=>true)
    PartComponentProcedure.create(:name=>"delete",:actions=>":destroy:",:component_id=>component.id, :contextual=>true)

  end

  def self.down
    drop_table :part_component_procedures
    drop_table :part_components
    drop_table :parts
    remove_column :users, :company_id
    drop_table :companies
    drop_table :users
    drop_table :sessions
  end
end
