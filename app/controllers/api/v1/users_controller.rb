# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [ :show, :update, :destroy, :deactivate, :activate ]

      def index
        users = User.ordered
        users = users.by_role(Role.find_by(name: params[:role])) if params[:role].present?
        users = users.by_department(Department.find(params[:department_id])) if params[:department_id].present?

        paginated = paginate(users, params[:per_page] || 20)

        json_response({
          data: UserSerializer.serialize_collection(paginated[:data]),
          pagination: paginated[:pagination]
        })
      end

      def show
        authorize @user
        json_response(UserSerializer.new(@user).serialize)
      end

      def create
        authorize User
        user = User.new(user_params)

        if user.save
          json_response(UserSerializer.new(user).serialize, :created)
        else
          error_response("Failed to create user", :unprocessable_entity, user.errors)
        end
      end

      def update
        authorize @user

        if @user.update(user_update_params)
          json_response(UserSerializer.new(@user).serialize)
        else
          error_response("Failed to update user", :unprocessable_entity, @user.errors)
        end
      end

      def destroy
        authorize @user
        @user.destroy
        json_response({ message: "User deleted successfully" }, :ok)
      end

      def deactivate
        authorize @user
        @user.deactivate!
        json_response(UserSerializer.new(@user).serialize)
      end

      def activate
        authorize @user
        @user.activate!
        json_response(UserSerializer.new(@user).serialize)
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:email, :full_name, :password, :password_confirmation, :role_id, :department_id)
      end

      def user_update_params
        permitted = [ :full_name, :department_id ]
        permitted << :email if current_user.admin?
        permitted << :role_id if current_user.admin?
        params.require(:user).permit(*permitted)
      end
    end
  end
end
