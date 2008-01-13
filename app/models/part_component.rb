# == Schema Information
# Schema version: 8
#
# Table name: part_components
#
#  id           :integer       not null, primary key
#  name         :string(255)   not null
#  part_id      :integer       not null
#  position     :integer       
#  created_at   :datetime      not null
#  created_by   :integer       
#  updated_at   :datetime      not null
#  updated_by   :integer       
#  lock_version :integer       default(0), not null
#

class PartComponent < ActiveRecord::Base
  acts_as_list :scope=>:part_id

  def title
    l :parts, self.part.name, :components, self.name, :title
  end

  def description
    l :parts, self.part.name, :components, self.name, :description
  end

end
