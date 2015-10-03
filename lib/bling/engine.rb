module Bling
  class Engine < ::Rails::Engine
    isolate_namespace Bling

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
