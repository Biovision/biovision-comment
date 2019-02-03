require 'biovision/base'

module Biovision
  module Comment
    class Engine < ::Rails::Engine
      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot, :dir => 'spec/factories'
      end

      config.assets.precompile << %w(biovision/base/icons/*)
      config.assets.precompile << %w(biovision/base/placeholders/*)
    end
  end
end
