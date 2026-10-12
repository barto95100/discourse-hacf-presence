# frozen_string_literal: true

# name: discourse-hacf-presence
# about: Proxy mis en cache vers le webhook de présence HACF (n8n)
# version: 0.1.0
# authors: HACF Infra
# url: https://github.com/barto95100/discourse-hacf-presence

enabled_site_setting :hacf_presence_enabled

module ::HacfPresence
  PLUGIN_NAME = "discourse-hacf-presence"
end

require_relative "lib/hacf_presence/engine"

register_asset "stylesheets/hacf-presence.scss"

after_initialize do
  require_relative "app/controllers/hacf_presence/presence_controller"
end
