# frozen_string_literal: true

module Api
  module V1
    class CommentsController < BaseController
      before_action :set_ticket
      before_action :set_comment, only: [ :show, :update, :destroy ]

      def index
        comments = @ticket.comments.ordered
        comments = comments.public_comments unless current_user.agent?

        json_response({
          data: comments.map { |c| serialize_comment(c) },
          ticket_id: @ticket.id
        })
      end

      def show
        authorize @comment
        json_response(serialize_comment(@comment))
      end

      def create
        comment = @ticket.comments.build(comment_params)
        comment.user = current_user

        if comment.save
          TicketHistory.create(
            ticket_id: @ticket.id,
            user_id: current_user.id,
            action: :commented,
            details: { internal: comment.is_internal }
          )
          json_response(serialize_comment(comment), :created)
        else
          error_response("Failed to create comment", :unprocessable_entity, comment.errors)
        end
      end

      def update
        authorize @comment

        if @comment.update(comment_update_params)
          json_response(serialize_comment(@comment))
        else
          error_response("Failed to update comment", :unprocessable_entity, @comment.errors)
        end
      end

      def destroy
        authorize @comment
        @comment.destroy
        json_response({ message: "Comment deleted successfully" }, :ok)
      end

      private

      def set_ticket
        @ticket = Ticket.find(params[:ticket_id])
      end

      def set_comment
        @comment = @ticket.comments.find(params[:id])
      end

      def comment_params
        params.require(:comment).permit(:content, :is_internal, :comment_type)
      end

      def comment_update_params
        params.require(:comment).permit(:content)
      end

      def serialize_comment(comment)
        {
          id: comment.id,
          content: comment.content,
          is_internal: comment.is_internal,
          comment_type: comment.comment_type,
          user: {
            id: comment.user.id,
            email: comment.user.email,
            full_name: comment.user.full_name
          },
          created_at: comment.created_at.iso8601,
          updated_at: comment.updated_at.iso8601
        }
      end
    end
  end
end
