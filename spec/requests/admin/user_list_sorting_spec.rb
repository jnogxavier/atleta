require 'rails_helper'

RSpec.describe 'Admin User List Sorting', type: :request do
  let(:admin) { create(:user, :admin) }

  before do
    post session_path, params: { email_address: admin.email_address, password: admin.password }
  end

  describe 'GET /admin/dashboard with sorting' do
    let!(:active_student) { create(:user, :student, name: 'Alice Active', email_address: 'alice@test.com', created_at: 3.days.ago) }
    let!(:deactivated_student) { create(:user, :student, name: 'Bob Deactivated', email_address: 'bob@test.com', deactivated_at: 1.day.ago, created_at: 2.days.ago) }
    let!(:active_partner) { create(:user, :partner, name: 'Charlie Partner', email_address: 'charlie@test.com', created_at: 1.day.ago) }

    context 'default sorting' do
      it 'sorts by status (active first), then role, name, email' do
        get admin_dashboard_path

        expect(response).to have_http_status(:success)

        # Parse the HTML to check order
        doc = Nokogiri::HTML(response.body)
        user_rows = doc.css('#users-table-body tr')

        # Should be ordered: active users (admin, partner, student), then deactivated users
        # Within active: admin < partner < student (alphabetically)
        emails = user_rows.map { |row| row.css('td')[1]&.text&.strip }

        # Find positions
        admin_pos = emails.index(admin.email_address)
        partner_pos = emails.index(active_partner.email_address)
        student_pos = emails.index(active_student.email_address)
        deactivated_pos = emails.index(deactivated_student.email_address)

        # Active users should come before deactivated
        expect(admin_pos).to be < deactivated_pos
        expect(partner_pos).to be < deactivated_pos
        expect(student_pos).to be < deactivated_pos

        # Among active users, check role ordering (admin < student < partner based on enum values)
        expect(admin_pos).to be < student_pos
        expect(student_pos).to be < partner_pos
      end
    end

    context 'sorting by status' do
      it 'sorts active users first when direction is asc' do
        get admin_dashboard_path(sort: 'status', direction: 'asc')

        expect(response).to have_http_status(:success)

        doc = Nokogiri::HTML(response.body)
        user_rows = doc.css('#users-table-body tr')

        # Active users should come first (admin, partner, student), then deactivated
        first_three_emails = user_rows[0..2].map { |row| row.css('td')[1].text.strip }
        expect(first_three_emails).to include(admin.email_address, active_partner.email_address, active_student.email_address)

        last_email = user_rows[3].css('td')[1].text.strip
        expect(last_email).to eq(deactivated_student.email_address)
      end

      it 'sorts deactivated users first when direction is desc' do
        get admin_dashboard_path(sort: 'status', direction: 'desc')

        expect(response).to have_http_status(:success)

        doc = Nokogiri::HTML(response.body)
        user_rows = doc.css('#users-table-body tr')

        # Deactivated user should come first
        first_email = user_rows[0].css('td')[1].text.strip
        expect(first_email).to eq(deactivated_student.email_address)
      end
    end

    context 'sorting by role' do
      it 'sorts by role ascending' do
        get admin_dashboard_path(sort: 'role', direction: 'asc')

        expect(response).to have_http_status(:success)

        doc = Nokogiri::HTML(response.body)
        user_rows = doc.css('#users-table-body tr')

        # Extract emails and roles to check order
        users_data = user_rows.map do |row|
          {
            email: row.css('td')[1]&.text&.strip,
            role_badge: row.css('td')[2]&.text&.strip
          }
        end

        emails = users_data.map { |d| d[:email] }

        admin_pos = emails.index(admin.email_address)
        partner_pos = emails.index(active_partner.email_address)
        student_pos = emails.index(active_student.email_address)

        # Role enum values determine order: admin (0) < student (1) < partner (2)
        # Count how many of each role we have
        admin_count = users_data.count { |d| d[:role_badge].include?('Admin') }
        student_count = users_data.count { |d| d[:role_badge].include?('Aluno') }

        # Admin should be in the admin section (0 to admin_count-1)
        expect(admin_pos).to be < admin_count

        # Student should be in the student section (admin_count to admin_count+student_count-1)
        expect(student_pos).to be >= admin_count
        expect(student_pos).to be < (admin_count + student_count)

        # Partner should be after all admins and students
        expect(partner_pos).to be >= (admin_count + student_count)
      end

      it 'sorts by role descending' do
        get admin_dashboard_path(sort: 'role', direction: 'desc')

        expect(response).to have_http_status(:success)

        doc = Nokogiri::HTML(response.body)
        user_rows = doc.css('#users-table-body tr')

        # Extract emails to check order
        emails = user_rows.map { |row| row.css('td')[1]&.text&.strip }

        admin_pos = emails.index(admin.email_address)
        partner_pos = emails.index(active_partner.email_address)
        student_pos = emails.index(active_student.email_address)

        # Descending order by enum values: partner (2) > student (1) > admin (0)
        expect(partner_pos).to be < student_pos
        expect(student_pos).to be < admin_pos
      end
    end

    context 'sorting by email' do
      it 'sorts by email ascending' do
        get admin_dashboard_path(sort: 'email', direction: 'asc')

        expect(response).to have_http_status(:success)

        doc = Nokogiri::HTML(response.body)
        user_rows = doc.css('#users-table-body tr')

        emails = user_rows.map { |row| row.css('td')[1].text.strip }
        expect(emails).to eq(emails.sort)
      end

      it 'sorts by email descending' do
        get admin_dashboard_path(sort: 'email', direction: 'desc')

        expect(response).to have_http_status(:success)

        doc = Nokogiri::HTML(response.body)
        user_rows = doc.css('#users-table-body tr')

        emails = user_rows.map { |row| row.css('td')[1].text.strip }
        expect(emails).to eq(emails.sort.reverse)
      end
    end

    context 'sorting by created_at' do
      it 'sorts by created date ascending (oldest first)' do
        get admin_dashboard_path(sort: 'created_at', direction: 'asc')

        expect(response).to have_http_status(:success)

        doc = Nokogiri::HTML(response.body)
        user_rows = doc.css('#users-table-body tr')

        # Extract emails
        emails = user_rows.map { |row| row.css('td')[1]&.text&.strip }

        student_pos = emails.index(active_student.email_address)
        deactivated_pos = emails.index(deactivated_student.email_address)
        partner_pos = emails.index(active_partner.email_address)

        # Oldest should come first: active_student (3 days) < deactivated_student (2 days) < active_partner (1 day)
        expect(student_pos).to be < deactivated_pos
        expect(deactivated_pos).to be < partner_pos
      end

      it 'sorts by created date descending (newest first)' do
        get admin_dashboard_path(sort: 'created_at', direction: 'desc')

        expect(response).to have_http_status(:success)

        doc = Nokogiri::HTML(response.body)
        user_rows = doc.css('#users-table-body tr')

        # Extract emails
        emails = user_rows.map { |row| row.css('td')[1]&.text&.strip }

        # The admin user is created "now" in the before block (most recent)
        # Then active_partner (1 day ago), deactivated_student (2 days), active_student (3 days)
        admin_pos = emails.index(admin.email_address)
        partner_pos = emails.index(active_partner.email_address)

        # Most recent should come first
        expect(admin_pos).to be < partner_pos
      end
    end

    context 'sorting indicators' do
      it 'shows ascending indicator when sorting by email asc' do
        get admin_dashboard_path(sort: 'email', direction: 'asc')

        expect(response.body).to include('M5 15l7-7 7 7') # Up arrow SVG path
      end

      it 'shows descending indicator when sorting by email desc' do
        get admin_dashboard_path(sort: 'email', direction: 'desc')

        expect(response.body).to include('M19 9l-7 7-7-7') # Down arrow SVG path
      end

      it 'shows correct sort links that toggle direction' do
        get admin_dashboard_path(sort: 'role', direction: 'asc')

        # The role header link should now point to desc
        expect(response.body).to include('sort=role')
        expect(response.body).to include('direction=desc')
      end
    end
  end

  describe 'sorting maintains active/deactivated distinction' do
    let!(:user_a_active) { create(:user, :student, name: 'A Active', email_address: 'a@test.com', role: 'student') }
    let!(:user_b_deactivated) { create(:user, :student, name: 'B Deactivated', email_address: 'b@test.com', role: 'student', deactivated_at: Time.current) }
    let!(:user_c_active) { create(:user, :student, name: 'C Active', email_address: 'c@test.com', role: 'student') }

    it 'when sorting by status, groups active and deactivated users separately' do
      get admin_dashboard_path(sort: 'status', direction: 'asc')

      expect(response).to have_http_status(:success)

      doc = Nokogiri::HTML(response.body)
      user_rows = doc.css('#users-table-body tr')

      # All active users (including admin) should come before deactivated
      active_count = 3 # admin, user_a_active, user_c_active
      first_rows = user_rows[0...active_count]
      last_rows = user_rows[active_count..]

      # Check that none of the first rows contain "Desativado"
      first_rows.each do |row|
        expect(row.text).not_to include('Desativado')
      end

      # Check that the deactivated user is in the last rows
      expect(last_rows.map(&:text).join).to include(user_b_deactivated.email_address)
      expect(last_rows.map(&:text).join).to include('Desativado')
    end
  end
end
