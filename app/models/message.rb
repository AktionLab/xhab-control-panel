class Message < ActiveRecord::Base
  belongs_to :component
  attr_accessible :text
end
