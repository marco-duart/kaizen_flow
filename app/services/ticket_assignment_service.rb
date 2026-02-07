# frozen_string_literal: true

class TicketAssignmentService
  def initialize(ticket)
    @ticket = ticket
  end

  def assign_automatically
    best_agent = find_best_agent
    return false unless best_agent

    @ticket.update(assignee_id: best_agent.id)

    TicketHistory.create(
      ticket_id: @ticket.id,
      user_id: best_agent.id,
      action: :assigned,
      details: { assigned_to: best_agent.email }
    )

    true
  end

  def assign_to_agent(agent)
    return false unless agent.agent?

    @ticket.update(assignee_id: agent.id)

    TicketHistory.create(
      ticket_id: @ticket.id,
      user_id: agent.id,
      action: :assigned,
      details: { assigned_by: "manual", assigned_to: agent.email }
    )

    true
  end

  def unassign
    @ticket.update(assignee_id: nil)

    TicketHistory.create(
      ticket_id: @ticket.id,
      user_id: @ticket.assignee_id,
      action: :assigned,
      details: { unassigned: true }
    )

    true
  end

  private

  def find_best_agent
    eligible_agents = eligible_agents_for_ticket

    return nil if eligible_agents.empty?

    least_busy_agent(eligible_agents)
  end

  def eligible_agents_for_ticket
    User.where(role: Role.find_by(name: "agent"), status: :active)
        .where("is_online = true OR is_online = false")
        .includes(:assigned_tickets)
        .to_a
  end

  def least_busy_agent(agents)
    agents.min_by do |agent|
      open_tickets = agent.assigned_tickets.open.count
      [ open_tickets, agent.id ]
    end
  end
end
