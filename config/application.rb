require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module KaizenFlow
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    config.middleware.use Rack::Cors do
      allow do
        origins "*"
        resource "*",
          headers: :any,
          expose: [ "access-token", "expiry", "token-type", "uid", "client" ],
          methods: [ :get, :post, :put, :patch, :delete, :options ]
      end
    end

    config.autoload_paths << Rails.root.join("app/services")
    config.autoload_paths << Rails.root.join("app/policies")
  end
end
