# == Schema Information
# Schema version: 9
#
# Table name: languages
#
#  id           :integer       not null, primary key
#  code         :string(255)   not null
#  active       :boolean       not null
#  created_at   :datetime      
#  created_by   :integer       
#  updated_at   :datetime      
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class Language < ActiveRecord::Base
  def before_save
    self.code = self.code.downcase
  end

  def title
     ("languages:"+self.code).t
  end
  alias :name :title
end
