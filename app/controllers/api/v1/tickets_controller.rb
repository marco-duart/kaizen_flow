# frozen_string_literal: true

module Api
  module V1
    class TicketsController < BaseController
      before_action :set_ticket, only: [ :show, :update, :destroy, :reopen ]

      def index
        tickets = Ticket.all
        tickets = filter_tickets(tickets)
        tickets = tickets.recent

        paginated = paginate(tickets, params[:per_page] || 20)

        json_response({
          data: TicketSerializer.serialize_collection(paginated[:data]),
          pagination: paginated[:pagination]
        })
      end

      def show
        authorize @ticket
        json_response(TicketSerializer.new(@ticket).serialize)
      end

      def create
        ticket = current_user.created_tickets.build(ticket_params)
        ticket.status = TicketStatus.find_by(name: "Open") || TicketStatus.first

        if ticket.save
          TicketAssignmentService.new(ticket).assign_automatically
          json_response(TicketSerializer.new(ticket).serialize, :created)
        else
          error_response("Failed to create ticket", :unprocessable_entity, ticket.errors)
        end
      end

      def update
        authorize @ticket

        if @ticket.update(ticket_update_params)
          TicketHistory.create(
            ticket_id: @ticket.id,
            user_id: current_user.id,
            action: :status_changed,
            details: { old_status: @ticket.status_was, new_status: @ticket.status.name }
          )
          json_response(TicketSerializer.new(@ticket).serialize)
        else
          error_response("Failed to update ticket", :unprocessable_entity, @ticket.errors)
        end
      end

      def destroy
        authorize @ticket
        @ticket.destroy
        json_response({ message: "Ticket deleted successfully" }, :ok)
      end

      def reopen
        authorize @ticket

        if @ticket.reopen!
          TicketHistory.create(
            ticket_id: @ticket.id,
            user_id: current_user.id,
            action: :reopened
          )
          json_response(TicketSerializer.new(@ticket).serialize)
        else
          error_response("Failed to reopen ticket", :unprocessable_entity)
        end
      end

      private

      def set_ticket
        @ticket = Ticket.find(params[:id])
      end

      def ticket_params
        params.require(:ticket).permit(
          :subject, :description, :category_id, :priority_id, :unit_id, :room_id,
          custom_data: {}
        )
      end

      def ticket_update_params
        permitted = [ :subject, :description, :status_id, :priority_id, :assignee_id, :room_id ]
        permitted << { custom_data: {} }
        params.require(:ticket).permit(*permitted)
      end

      def filter_tickets(tickets)
        tickets = tickets.by_priority(params[:priority_id]) if params[:priority_id].present?
        tickets = tickets.for_category(params[:category_id]) if params[:category_id].present?
        tickets = tickets.for_assignee(params[:assignee_id]) if params[:assignee_id].present?
        tickets = tickets.for_requester(params[:requester_id]) if params[:requester_id].present?
        tickets = tickets.for_unit(params[:unit_id]) if params[:unit_id].present?

        case params[:status]
        when "open"
          tickets = tickets.open
        when "closed"
          tickets = tickets.closed
        when "assigned"
          tickets = tickets.assigned
        when "unassigned"
          tickets = tickets.unassigned
        end

        tickets
      end
    end
  end
end
