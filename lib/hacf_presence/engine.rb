# frozen_string_literal: true

module ::HacfPresence
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace HacfPresence
  end
end
