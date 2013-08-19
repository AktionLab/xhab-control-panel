class Datum < ActiveRecord::Base
  belongs_to :component
  attr_accessible :value
end
