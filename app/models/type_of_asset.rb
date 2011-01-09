class TypeOfAsset < ActiveRecord::Base
  has_many :postings
end