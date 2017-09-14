module Biovision
  module Comment
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
