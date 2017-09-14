module Biovision
  module Comment
    class Engine < ::Rails::Engine
      config.assets.precompile << %w(biovision/base/icons/*)
      config.assets.precompile << %w(biovision/base/placeholders/*)
    end

    require 'biovision/base'
  end
end
