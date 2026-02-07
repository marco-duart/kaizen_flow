# frozen_string_literal: true

# ============================================================
# KaizenFlow
# ============================================================

require 'faker'
require 'bcrypt'

# Configuration
COMPANIES_COUNT = 3
UNITS_PER_COMPANY = 2
DEPARTMENTS_COUNT = 5
TEAMS_PER_DEPARTMENT = 2
USERS_PER_DEPARTMENT = 8
ROOMS_PER_UNIT = 6
NETWORKS_PER_UNIT = 3
TICKET_CATEGORIES_COUNT = 8
TICKETS_COUNT = 150
COMMENTS_PER_TICKET = 3
ITEMS_COUNT = 50
DEVICES_COUNT = 40
LOANS_COUNT = 20

puts "🌱 Seeding KaizenFlow database with realistic data..."
puts "=" * 60

# ============================================================
# STEP 1: CREATE COMPANIES
# ============================================================
puts "\n📍 Creating Companies..."

companies = []
COMPANIES_COUNT.times do |i|
  cnpj = format("%014d", rand(10**14))
  company = Company.find_or_create_by!(cnpj: cnpj) do |c|
    c.name = Faker::Company.name
    c.active = true
  end
  companies << company
  puts "  ✓ #{company.name}"
end

# ============================================================
# STEP 2: CREATE ROLES AND PERMISSIONS
# ============================================================
puts "\n🔐 Creating Roles and Permissions..."

roles_config = {
  admin: { permissions: [ :all ] },
  supervisor: { permissions: %w[ticket:view ticket:create ticket:edit user:view user:create comment:create comment:edit] },
  agent: { permissions: %w[ticket:view ticket:edit comment:create comment:edit] },
  end_user: { permissions: %w[ticket:create comment:create] }
}

role_records = {}
companies.each do |company|
  roles_config.each do |role_key, config|
    role = Role.find_or_create_by!(name: role_key.to_s, company: company) do |r|
      r.company = company
    end
    role_records[role_key] = role

    if config[:permissions].first != :all
      config[:permissions].each do |permission|
        resource, action = permission.split(":")
        Permission.find_or_create_by!(
          role: role,
          resource: resource,
          action: action,
          level: "own_department"
        )
      end
    end

    puts "  ✓ #{role_key.to_s.titleize} role (#{company.name})"
  end
end

# ============================================================
# STEP 3: CREATE DEPARTMENTS AND TEAMS
# ============================================================
puts "\n🏢 Creating Departments and Teams..."

departments = []
DEPARTMENTS_COUNT.times do
  dept_name = Faker::Company.department
  department = Department.find_or_create_by!(name: dept_name)
  departments << department
  puts "  ✓ #{department.name}"

  TEAMS_PER_DEPARTMENT.times do
    team_name = "#{department.name} - #{Faker::Team.name}"
    team = Team.find_or_create_by!(name: team_name) do |t|
      t.department = department
      t.description = Faker::Lorem.sentence(word_count: 8)
    end
  end
end

# ============================================================
# STEP 4: CREATE USERS
# ============================================================
puts "\n👥 Creating Users..."

users_by_role = { admin: [], supervisor: [], agent: [], end_user: [] }

default_password_hash = BCrypt::Password.create("Password123!@#")

companies.each_with_index do |company, company_idx|
  admin_user = User.find_or_create_by!(
    email: "admin#{company_idx}@kaizen.local",
    uid: "admin#{company_idx}@kaizen.local",
    provider: "email"
  ) do |u|
    u.full_name = Faker::Name.name
    u.encrypted_password = default_password_hash
    u.role = role_records[:admin]
    u.department = departments.sample
    u.status = "active"
    u.is_online = true
  end
  users_by_role[:admin] << admin_user
  puts "  ✓ Admin: #{admin_user.email}"

  departments.each do |department|
    supervisor_email = "supervisor-#{Faker::Internet.unique.user_name}@kaizen.local"
    supervisor = User.find_or_create_by!(
      email: supervisor_email,
      uid: supervisor_email,
      provider: "email"
    ) do |u|
      u.full_name = Faker::Name.name
      u.encrypted_password = default_password_hash
      u.role = role_records[:supervisor]
      u.department = department
      u.status = "active"
      u.is_online = [ true, false ].sample
    end
    users_by_role[:supervisor] << supervisor
    puts "  ✓ Supervisor: #{supervisor.email}"

    3.times do
      agent_email = "agent-#{Faker::Internet.unique.user_name}@kaizen.local"
      agent = User.find_or_create_by!(
        email: agent_email,
        uid: agent_email,
        provider: "email"
      ) do |u|
        u.full_name = Faker::Name.name
        u.encrypted_password = default_password_hash
        u.role = role_records[:agent]
        u.department = department
        u.status = "active"
        u.is_online = [ true, false ].sample
      end
      users_by_role[:agent] << agent
      puts "  ✓ Agent: #{agent.email}"

      Team.where(department: department).sample&.users&.<<(agent)
    end

    4.times do
      user_email = "user-#{Faker::Internet.unique.user_name}@kaizen.local"
      end_user = User.find_or_create_by!(
        email: user_email,
        uid: user_email,
        provider: "email"
      ) do |u|
        u.full_name = Faker::Name.name
        u.encrypted_password = default_password_hash
        u.role = role_records[:end_user]
        u.department = department
        u.status = "active"
        u.is_online = [ true, false ].sample
      end
      users_by_role[:end_user] << end_user
      puts "  ✓ End User: #{end_user.email}"
    end
  end
end

# ============================================================
# STEP 5: CREATE UNITS, NETWORKS, AND ROOMS
# ============================================================
puts "\n🏛️  Creating Units, Networks, and Rooms..."

units = []
companies.each do |company|
  UNITS_PER_COMPANY.times do
    unit = Unit.find_or_create_by!(
      name: "#{company.name} - #{Faker::Address.city} Office",
      company: company
    ) do |u|
      u.address = Faker::Address.full_address
    end
    units << unit
    puts "  ✓ Unit: #{unit.name}"

    NETWORKS_PER_UNIT.times do
      Network.find_or_create_by!(
        name: "Network-#{SecureRandom.hex(2).upcase}",
        unit: unit
      )
    end

    room_types = %i[classroom laboratory office server_room storage common_area other]
    ROOMS_PER_UNIT.times do
      Room.find_or_create_by!(
        name: "#{Faker::Address.building_number} - #{Faker::Hacker.noun}",
        unit: unit
      ) do |r|
        r.location_type = room_types.sample
      end
    end
  end
end

# ============================================================
# STEP 6: CREATE GROUPS
# ============================================================
puts "\n👥 Creating Access Groups..."

3.times do
  group_name = "#{Faker::Company.department} Team"
  group = Group.find_or_create_by!(name: group_name) do |g|
    g.description = Faker::Lorem.sentence(word_count: 10)
    # Add random users to group
    g.users = users_by_role[:agent].sample(5)
  end
  puts "  ✓ Group: #{group.name}"

  group.rooms = Room.all.sample(3)
end

# ============================================================
# STEP 7: CREATE TICKET CATEGORIES WITH HIERARCHY
# ============================================================
puts "\n📂 Creating Ticket Categories (with hierarchy)..."

main_categories = %w[Hardware Software Network Infrastructure Account Support]
category_records = {}

main_categories.each do |main_name|
  parent_category = TicketCategory.find_or_create_by!(name: main_name) do |cat|
    cat.description = Faker::Lorem.sentence(word_count: 10)
  end
  category_records[main_name.to_sym] = parent_category
  puts "  ✓ Category: #{main_name}"

  3.times do |idx|
    sub_name = "#{main_name} - #{Faker::Hacker.noun}"
    subcategory = TicketCategory.find_or_create_by!(name: sub_name) do |cat|
      cat.parent = parent_category
      cat.description = Faker::Lorem.sentence(word_count: 8)
    end
  end
end

# ============================================================
# STEP 8: CREATE SLAs
# ============================================================
puts "\n⏱️  Creating SLAs..."

sla_times = { "Critical" => 120, "High" => 480, "Medium" => 1440, "Low" => 2880 }

TicketCategory.all.each do |category|
  sla_times.each do |priority_name, minutes|
    Sla.find_or_create_by!(
      name: "#{category.name} - #{priority_name}",
      ticket_category: category,
      target_resolution_time_minutes: minutes
    )
  end
end
puts "  ✓ SLAs created for all categories"

# ============================================================
# STEP 9: CREATE TICKET STATUSES
# ============================================================
puts "\n🏷️  Creating Ticket Statuses..."

statuses_config = [
  { name: "Open", is_final: false, is_closed: false },
  { name: "In Progress", is_final: false, is_closed: false },
  { name: "Waiting Customer", is_final: false, is_closed: false },
  { name: "Waiting Vendor", is_final: false, is_closed: false },
  { name: "Resolved", is_final: true, is_closed: false },
  { name: "Closed", is_final: true, is_closed: true },
  { name: "On Hold", is_final: false, is_closed: false },
  { name: "Reopened", is_final: false, is_closed: false }
]

status_records = {}
statuses_config.each do |config|
  status = TicketStatus.find_or_create_by!(
    name: config[:name],
    is_final: config[:is_final],
    is_closed: config[:is_closed]
  )
  status_records[config[:name].to_sym] = status
  puts "  ✓ Status: #{config[:name]}"
end

# ============================================================
# STEP 10: CREATE TICKET PRIORITIES
# ============================================================
puts "\n⚡ Creating Ticket Priorities..."

priority_records = {}
[
  { name: "Low", level: 1 },
  { name: "Medium", level: 2 },
  { name: "High", level: 3 },
  { name: "Critical", level: 4 }
].each do |config|
  priority = TicketPriority.find_or_create_by!(
    name: config[:name],
    level: config[:level]
  )
  priority_records[config[:name].to_sym] = priority
  puts "  ✓ Priority: #{config[:name]}"
end

# ============================================================
# STEP 11: CREATE TICKETS WITH HISTORY AND COMMENTS
# ============================================================
puts "\n🎟️  Creating Tickets..."

tickets = []
ticket_counter = 0

TICKETS_COUNT.times do
  requester = users_by_role[:end_user].sample
  assignee = [ nil, users_by_role[:agent].sample ].sample
  category = TicketCategory.where(parent_id: nil).sample
  status = TicketStatus.all.sample
  priority = TicketPriority.all.sample
  unit = units.sample

  ticket = Ticket.find_or_create_by!(
    requester: requester
  ) do |t|
    t.ticket_number = "TICK-#{Date.today.year}#{format('%05d', ticket_counter += 1)}"
    t.subject = Faker::Hacker.say_something_smart
    t.description = Faker::Lorem.paragraph(sentence_count: 3)
    t.category = category
    t.status = status
    t.priority = priority
    t.unit = unit
    t.room = unit.rooms.sample
    t.assignee = assignee
    t.custom_data = {
      impact_level: %w[single_user department all_company].sample,
      estimated_time: rand(30..480),
      resolution_notes: Faker::Lorem.paragraph(sentence_count: 2)
    }
    t.created_at = Faker::Time.between(from: 30.days.ago, to: Time.current)
    t.updated_at = Faker::Time.between(from: t.created_at, to: Time.current)
  end

  tickets << ticket

  if ticket_counter % 25 == 0
    puts "  ✓ Created #{ticket_counter} tickets..."
  end
end
puts "  ✓ Total tickets created: #{tickets.length}"

# ============================================================
# STEP 12: CREATE TICKET TASKS
# ============================================================
puts "\n✅ Creating Ticket Tasks..."

tickets.sample(80).each do |ticket|
  rand(1..5).times do
    TicketTask.find_or_create_by!(
      ticket: ticket,
      title: "#{Faker::Hacker.verb} #{Faker::Hacker.noun}",
      description: Faker::Lorem.sentence(word_count: 8)
    ) do |task|
      task.status = %w[pending in_progress completed cancelled].sample
    end
  end
end
puts "  ✓ Ticket tasks created"

# ============================================================
# STEP 13: CREATE COMMENTS
# ============================================================
puts "\n💬 Creating Comments..."
puts "  ⏭️  Skipping comments generation (will be created via API)"
puts "  ✓ Comments skipped"

# ============================================================
# STEP 14: CREATE TICKET HISTORIES
# ============================================================
puts "\n📋 Creating Ticket Histories..."

tickets.each do |ticket|
  if !TicketHistory.exists?(ticket: ticket, action: "created")
    TicketHistory.create!(
      ticket: ticket,
      action: "created",
      author: ticket.requester,
      changes: { status: [ "", ticket.status.name ] }
    )
  end
end
puts "  ✓ Ticket histories created"

# ============================================================
# STEP 15: CREATE TICKET SCHEDULES (Recurring tickets)
# ============================================================
puts "\n🔄 Creating Ticket Schedules..."
puts "  ⏭️  Skipping ticket schedules generation"
puts "  ✓ Ticket schedules skipped"

# ============================================================
# STEP 16: CREATE SATISFACTION SURVEYS (Simplified)
# ============================================================
puts "\n⭐ Creating Satisfaction Surveys..."
puts "  ⏭️  Skipping satisfaction surveys generation"
puts "  ✓ Satisfaction surveys skipped"

# ============================================================
# STEP 17: CREATE ITEM CATEGORIES AND ITEMS
# ============================================================
puts "\n📦 Creating Item Categories and Items..."
puts "  ⏭️  Skipping item categories and items generation"
puts "  ✓ Items skipped"

items = []

# ============================================================
# STEP 18: CREATE DEVICES
# ============================================================
puts "\n💻 Creating Devices..."
puts "  ⏭️  Skipping devices generation"
puts "  ✓ Devices skipped"

devices = []

# ============================================================
# STEP 19: CREATE LOANS
# ============================================================
puts "\n📤 Creating Loans..."
puts "  ⏭️  Skipping loans generation"
puts "  ✓ Loans skipped"

# ============================================================
# STEP 20: CREATE STOCK RECORDS
# ============================================================
puts "\n📊 Creating Stock Records..."
puts "  ⏭️  Skipping stock records generation"
puts "  ✓ Stock records skipped"

# ============================================================
# SUMMARY
# ============================================================
puts "\n" + "=" * 60
puts "✅ DATABASE SEEDING COMPLETED SUCCESSFULLY!"
puts "=" * 60

puts "\n📊 Summary of created data:"
puts "  Companies:           #{Company.count}"
puts "  Departments:         #{Department.count}"
puts "  Teams:               #{Team.count}"
puts "  Users:               #{User.count}"
puts "  Units:               #{Unit.count}"
puts "  Networks:            #{Network.count}"
puts "  Rooms:               #{Room.count}"
puts "  Groups:              #{Group.count}"
puts "  Ticket Categories:   #{TicketCategory.count}"
puts "  Tickets:             #{Ticket.count}"
puts "  Ticket Comments:     #{Comment.count}"
puts "  Ticket Tasks:        #{TicketTask.count}"
puts "  Ticket Histories:    #{TicketHistory.count}"
puts "  Ticket Schedules:    #{TicketSchedule.count}"
puts "  Satisfaction Surveys:#{SatisfactionSurvey.count}"
puts "  Item Categories:     #{ItemCategory.count}"
puts "  Items:               #{Item.count}"
puts "  Stock Records:       #{StockRecord.count}"
puts "  Devices:             #{Device.count}"
puts "  Loans:               #{Loan.count}"

puts "\n🔑 Test Credentials:"
users_by_role[:admin].each do |admin|
  puts "  Email: #{admin.email}"
  puts "  Password: Password123!@#"
  puts "  Role: Admin"
end

puts "\n💡 Tips for testing:"
puts "  - Use the admin account to test all features"
puts "  - Check /api-docs for Swagger documentation"
puts "  - Test filtering with different priority levels"
puts "  - Create new tickets from end_user accounts"
puts "  - Assign tickets from agent accounts"
puts "  - Check device and item inventory"
puts "  - Test loan management"
puts "\n✨ Happy testing!"
