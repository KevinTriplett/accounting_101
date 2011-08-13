class TypeOfAsset < ActiveRecord::Base
  has_many :postings
  validates :name, :presence => true
  validates :conversion, :presence => true
end