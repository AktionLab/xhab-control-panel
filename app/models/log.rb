class Log < ActiveRecord::Base
  belongs_to :component
  attr_accessible :message, :type
end
