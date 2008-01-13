# == Schema Information
# Schema version: 9
#
# Table name: parts
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  code         :string(8)     not null
#  active       :boolean       default(TRUE), not null
#  image_url    :string(255)   
#  position     :integer       
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class Part < ActiveRecord::Base
	PUBLIC         = "PUB"
	ADMINISTRATION = "ADM"
	ORGANISATION   = "ORG"
	RELATIONSHIP   = "REL"
	ACCOUNTANCY    = "ACC"
	SALES          = "SAL"

  acts_as_list

  def title
    l :parts, self.name, :title
  end

  def description
    l :parts, self.name, :description
  end

end
