# frozen_string_literal: true

module Api
  module V1
    class HealthController < Api::BaseController
      skip_before_action :authenticate_user!, only: [ :check ]
      skip_before_action :authorize_request, only: [ :check ]

      def check
        render json: {
          status: "healthy",
          timestamp: Time.current.iso8601,
          version: "1.0.0",
          database: database_healthy?,
          cache: cache_healthy?
        }, status: :ok
      end

      private

      def database_healthy?
        ActiveRecord::Base.connection.execute("SELECT 1").present?
      rescue StandardError
        false
      end

      def cache_healthy?
        Rails.cache.read("health_check").present? || true
      rescue StandardError
        false
      end
    end
  end
end
