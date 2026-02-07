# frozen_string_literal: true

# Configuration for devise_token_auth
# Provides secure token-based authentication for API endpoints

DeviseTokenAuth.setup do |config|
  # By default the authorization headers will be looked for at
  # ["Authorization", "X-Authorization"]. If you want to add custom headers
  # you can use the following syntax:
  config.headers_names = {
    "Authorization" => "authorization",
    "X-Authorization" => "x-authorization"
  }

  # By default, only Bearer tokens are supported. If, however, you wish to
  # integrate with legacy Devise authentication, you can do so by enabling
  # the below flag. NOTE: This feature is intended to simplify the transition
  # from legacy Devise authentication to devise-token-auth for existing
  # Rails apps only. It has security implications and therefore is DISABLED
  # by default. See `config/routes.rb` for usage example.
  # config.enable_standard_devise_support = true

  # By default we will just use the `user_type` to determine, whether a token
  # is valid or not. Some scenarios however require additional verifications.
  # You can customize this behaviour by using the following method
  # config.token_validations_enabled = ["JtiClaimValidator"]

  # Configure the session persistence policy used by devise-token-auth.
  # By default `:with_duration` is used, which entails users to re-authenticate
  # after `token_lifespan` of inactivity.
  # config.session_persistence_policy = :with_duration

  # Set the max duration before a token is considered expired.
  # If set to nil, token duration will be infinite.
  # If `nil`, the duration will be read from the `duration` column if available.
  # Default 2 weeks
  config.token_lifespan = 2.weeks

  # Sometimes it's necessary to make several requests to one or more separate
  # user resources to perform fully during the authorization handshake.
  # This requires the request to make use of the same user afterwards.
  # Mongoose middleware in mAuth handles this use case, but since Rails
  # doesn't use the same middleware pattern, we need to fall back to a
  # query-string parameter (?access-token=xxxx) to maintain the same
  # user context.
  # Default false
  config.change_headers_on_each_request = true

  # By default, users will need to re-authenticate after each request. Specify
  # false to allow the same token to be reused until its expiration time.
  # config.skip_jwt_iat_validation = false
end
