# == Schema Information
# Schema version: 9
#
# Table name: users
#
#  id              :integer       not null, primary key
#  name            :string(32)    not null
#  hashed_password :string(255)   not null
#  salt            :string(255)   not null
#  locked          :boolean       not null
#  email           :string(255)   
#  created_at      :datetime      
#  created_by      :integer       
#  updated_at      :datetime      
#  updated_by      :integer       
#  lock_version    :integer       default(0), not null
#  company_id      :integer       not null
#  language_id     :integer       not null
#  role_id         :integer       not null
#

class User < ActiveRecord::Base
  cattr_accessor :current_user
	attr_accessor :password_confirmation
	validates_confirmation_of :password

	ADMIN = "admin"

	def validate
		error.add_to_base("Mot de passe manquant") if hashed_password.blank?
	end

	def password
		@password
	end
	
	def password=(passwd)
		@password = passwd
		self.salt = self.object_id.to_s[1..16] + rand.to_s[2..16]
		self.hashed_password = User.encrypted_password(self.password, self.salt)
	end

	def self.authenticate(name, password)
		user = self.find_by_name name
		if user
		  if user.locked
		    user = nil 
		  else
  			expected_password = encrypted_password(password, user.salt)
	  		if user.hashed_password != expected_password
	  			user = nil
	  		end
	  	end
		end
		user
	end
	
	def after_destroy
		if User.count.zero?
			raise "Impossible de détruire le dernier utilisateur"
		end
	end
	
	def parts
    parts = []
    if self.company.admin
		  parts = Part.find :all, :order=>:position, :conditions=>"active"
    elsif self.role.admin
		  parts = Part.find :all, :order=>:position, :conditions=>["code!=? AND active", Part::ADMINISTRATION]
    else
      self.role.allowed_procedures.each do |p|
        part = p.component.part
        parts << part if parts.index(part).nil? and part.active and part.code!=Part::ADMINISTRATION
			end
    end
    parts
	end

	def components(part)
    components = []
    if self.company.admin or (self.role.admin and part.code != Part::ADMINISTRATION)
		  components = part.components
    elsif part.code != Part::ADMINISTRATION
      components = PartComponent.find :all, :select=>" DISTINCT c.*", :joins=>"AS c JOIN rights AS r ON (c.id=r.component_id)", :conditions=>["r.active AND r.role_id=? AND c.part_id=?",self.role_id, part.id]
    end
    components
	end

	def procedures(component, contextual=nil)
    conditions = ""
    unless contextual.nil?
      conditions += contextual ? " AND p.contextual" : " AND NOT p.contextual"
    end
    procedures = []
    if self.company.admin or self.role.admin
      unless contextual.nil?
        procedures = PartComponentProcedure.find :all, :joins=>"AS p", :conditions=>["p.component_id=?"+conditions, component.id]
   		#  procedures = component.procedures
   		else
   		  procedures = component.procedures
		  end
    else
      procedures = PartComponentProcedure.find :all, :select=>" DISTINCT p.*", :joins=>"AS p JOIN rights AS r ON (p.id=r.procedure_id)", :conditions=>["r.active AND r.role_id=? AND p.component_id=?"+conditions, self.role_id, component.id]
    end
    procedures
	end

	private

	def self.encrypted_password(password, salt)
		string_to_hash = password + "OneMore" + salt
#		string_to_hash = password + salt
		Digest::MD5.hexdigest(string_to_hash)
	end

end
