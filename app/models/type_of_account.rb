class TypeOfAccount < ActiveRecord::Base
  has_many :accounts
  validates_presence_of :name
end
