# frozen_string_literal: true

HacfPresence::Engine.routes.draw { get "/" => "presence#show" }

Discourse::Application.routes.draw { mount ::HacfPresence::Engine, at: "/hacf-presence" }
