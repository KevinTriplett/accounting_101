class Journal < ActiveRecord::Base
  generator_for :description, "this is a journal entry"
end