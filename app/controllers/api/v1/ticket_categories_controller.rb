# frozen_string_literal: true

module Api
  module V1
    class TicketCategoriesController < BaseController
      before_action :set_ticket_category, only: [ :show, :update, :destroy ]

      def index
        categories = TicketCategory.root_categories.ordered

        json_response({
          data: categories.map { |c| serialize_category(c) }
        })
      end

      def show
        json_response(serialize_category_with_children(@ticket_category))
      end

      def create
        category = TicketCategory.new(category_params)

        if category.save
          json_response(serialize_category(category), :created)
        else
          error_response("Failed to create category", :unprocessable_entity, category.errors)
        end
      end

      def update
        if @ticket_category.update(category_params)
          json_response(serialize_category(@ticket_category))
        else
          error_response("Failed to update category", :unprocessable_entity, @ticket_category.errors)
        end
      end

      def destroy
        if @ticket_category.destroy
          json_response({ message: "Category deleted successfully" }, :ok)
        else
          error_response("Cannot delete category with tickets", :unprocessable_entity)
        end
      end

      private

      def set_ticket_category
        @ticket_category = TicketCategory.find(params[:id])
      end

      def category_params
        params.require(:ticket_category).permit(:name, :description, :parent_id)
      end

      def serialize_category(category)
        {
          id: category.id,
          name: category.name,
          description: category.description,
          parent_id: category.parent_id,
          has_children: category.has_children?,
          created_at: category.created_at.iso8601,
          updated_at: category.updated_at.iso8601
        }
      end

      def serialize_category_with_children(category)
        base = serialize_category(category)
        base[:children] = category.children.map { |child| serialize_category_with_children(child) }
        base[:custom_fields] = category.custom_fields.map { |field| serialize_custom_field(field) }
        base[:slas] = category.slas.map { |sla| serialize_sla(sla) }
        base
      end

      def serialize_custom_field(field)
        {
          id: field.id,
          name: field.name,
          field_type: field.field_type,
          is_required: field.is_required,
          options: field.options || {}
        }
      end

      def serialize_sla(sla)
        {
          id: sla.id,
          name: sla.name,
          target_resolution_time_minutes: sla.target_resolution_time_minutes,
          resolution_time_hours: sla.resolution_time_hours,
          resolution_time_days: sla.resolution_time_days
        }
      end
    end
  end
end
