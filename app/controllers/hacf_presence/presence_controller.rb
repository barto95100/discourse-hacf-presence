# frozen_string_literal: true

require "net/http"

module ::HacfPresence
  class PresenceController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    skip_before_action :check_xhr, :verify_authenticity_token, only: [:show]

    EMPTY = { updated: nil, count: 0, users: [], visitors: nil }.freeze

    def show
      raise Discourse::NotFound if SiteSetting.hacf_presence_login_required && !current_user

      ttl = SiteSetting.hacf_presence_cache_seconds
      data = Discourse.cache.fetch("hacf_presence_payload", expires_in: ttl.seconds) { fetch_remote }
      response.headers["Cache-Control"] = "private, max-age=#{ttl}"
      render json: data
    end

    private

    def fetch_remote
      uri = URI.parse(SiteSetting.hacf_presence_source_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 3
      http.read_timeout = 3
      res = http.get(uri.request_uri, "Accept" => "application/json")
      return EMPTY.dup unless res.is_a?(Net::HTTPSuccess)

      body = JSON.parse(res.body)
      {
        updated: body["updated"],
        count: body["count"].to_i,
        users: Array(body["users"]).first(50),
        visitors: body["visitors"],
      }
    rescue StandardError => e
      Rails.logger.warn("[hacf-presence] #{e.class}: #{e.message}")
      EMPTY.dup
    end
  end
end
