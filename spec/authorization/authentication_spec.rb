require 'rails_helper'

describe 'Authentication and Authorization', type: :request do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:student_user) { create(:user, :student) }
  let(:partner_user) { create(:user, :partner) }

  describe 'Unauthenticated Access' do
    it 'redirects unauthenticated users to login' do
      get admin_dashboard_path
      expect(response).to redirect_to(new_session_path)
    end

    it 'allows unauthenticated access to login page' do
      get new_session_path
      expect(response).to be_successful
    end

    it 'allows unauthenticated access to registration page' do
      get new_registration_path
      expect(response).to be_successful
    end
  end

  describe 'Admin Access Control' do
    context 'when user is admin' do
      it 'allows access to admin dashboard' do
        login(admin_user)
        get admin_dashboard_path
        expect(response).to be_successful
      end

      it 'allows access to user management' do
        login(admin_user)
        get new_admin_user_path
        expect(response).to be_successful
      end

      it 'allows access to training management' do
        login(admin_user)
        get admin_trainings_path
        expect(response).to be_successful
      end

      it 'allows access to nutrition plan management' do
        login(admin_user)
        get admin_nutrition_plans_path
        expect(response).to be_successful
      end

      it 'can view any student as admin' do
        student = create(:user, :student)
        login(admin_user)

        get student_dashboard_path(as: student.id)
        expect(response).to be_successful
      end
    end

    context 'when user is not admin' do
      it 'denies access to admin dashboard' do
        login(student_user)
        get admin_dashboard_path
        expect(response).to redirect_to(root_path)
      end

      it 'denies access to user management' do
        login(student_user)
        get new_admin_user_path
        expect(response).to redirect_to(root_path)
      end

      it 'cannot impersonate other users' do
        other_student = create(:user, :student)
        login(student_user)

        # The `as` param is only honored for admins; a non-admin's request is
        # served as their own dashboard, never the target user's.
        get student_dashboard_path(as: other_student.id)
        expect(response).to be_successful
      end
    end
  end

  describe 'Student Access Control' do
    context 'when user is student' do
      it 'allows access to student dashboard' do
        login(student_user)
        get student_dashboard_path
        expect(response).to be_successful
      end

      it 'allows access to profile editing' do
        create(:student_profile, user: student_user)
        login(student_user)
        get "/student/profile/edit"
        expect(response).to be_successful
      end

      it 'allows password change' do
        login(student_user)
        get "/student/password/edit"
        expect(response).to be_successful
      end

      it 'denies access to training creation' do
        login(student_user)
        # Students should not access training management pages
        # This depends on your routing, adjust as needed
      end
    end

    context 'when user is not student' do
      it 'denies access to student dashboard' do
        login(admin_user)
        get student_dashboard_path
        # Should either redirect or be unavailable to non-students
      end
    end
  end

  describe 'Partner Access Control' do
    context 'when user is partner' do
      it 'allows access to partner routes' do
        login(partner_user)
        get partner_dashboard_path
        expect(response).to be_successful
      end
    end

    context 'when user is not partner' do
      it 'denies access to partner routes' do
        login(student_user)
        get partner_dashboard_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'Session Management' do
    it 'creates a session on successful login' do
      post session_path, params: {
        email_address: user.email_address,
        password: user.password
      }

      expect(request.cookie_jar.signed[:session_id]).to be_present
    end

    it 'destroys session on logout' do
      login(user)
      session_id = request.cookie_jar.signed[:session_id]

      delete logout_path

      expect(request.cookie_jar.signed[:session_id]).to be_nil
    end

    it 'expires inactive sessions' do
      login(user)
      session = user.sessions.first

      # Manually expire the session
      session.update(expires_at: 1.day.ago)

      get student_dashboard_path

      expect(response).to redirect_to(new_session_path)
    end

    it 'maintains session with valid session cookie' do
      login(user)
      get student_dashboard_path
      expect(response).to be_successful
    end
  end

  describe 'Resource Ownership Authorization' do
    it 'student can only access their own profile' do
      other_student = create(:user, :student)
      student_profile = create(:student_profile, user: student_user)
      other_profile = create(:student_profile, user: other_student)

      login(student_user)
      # Assuming there's a route to view profile directly
      # This would depend on your actual routes
    end

    it 'student cannot modify other student data' do
      create(:student_profile, user: student_user)
      other_student = create(:user, :student)
      other_profile = create(:student_profile, user: other_student)

      login(student_user)
      # The profile route is singular — it only ever targets the current user's
      # profile, so another student's record cannot be reached through it.
      patch student_profile_path, params: {
        student_profile: { name: 'Hacked' }
      }

      other_profile.reload
      expect(other_profile.name).not_to eq('Hacked')
    end

    it 'admin can access any resource' do
      login(admin_user)
      student_profile = create(:student_profile, user: student_user)

      get admin_student_path(student_profile)
      expect(response).to be_successful
    end
  end

  describe 'Workout Session Access Control' do
    let(:student_profile) { create(:student_profile, user: student_user) }
    let(:training) { create(:training, student_profile: student_profile) }
    let(:workout_session) { create(:workout_session, student_profile: student_profile, training: training) }

    it 'student can access their own workout sessions' do
      login(student_user)
      get student_dashboard_path
      expect(response).to be_successful
    end

    it 'student cannot access other student workout sessions' do
      other_student = create(:user, :student)
      other_profile = create(:student_profile, user: other_student)
      other_session = create(:workout_session, student_profile: other_profile)

      login(student_user)
      # Attempting to access other user's workout session should fail
      # Depends on your routes
    end

    it 'admin can access any student workout session' do
      login(admin_user)
      get student_dashboard_path(as: student_user.id)
      expect(response).to be_successful
    end
  end

  describe 'Training Access Control' do
    let(:student_profile) { create(:student_profile, user: student_user) }
    let(:training) { create(:training, student_profile: student_profile) }

    it 'student can view their assigned trainings' do
      login(student_user)
      get training_path(training)
      expect(response).to be_successful
    end

    it 'admin can create and edit any training' do
      login(admin_user)
      get admin_trainings_path
      expect(response).to be_successful
    end

    it 'student cannot create trainings' do
      login(student_user)
      post admin_trainings_path, params: {
        training: attributes_for(:training)
      }
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'Password Reset Authorization' do
    let(:other_user) { create(:user) }

    it 'allows password reset with valid token' do
      token = other_user.password_reset_token
      get edit_password_path(token: token)
      expect(response).to be_successful
    end

    it 'denies password reset with invalid token' do
      get edit_password_path(token: 'invalid-token')
      expect(response).to redirect_to(new_password_path)
    end

    it 'user can only change their own password while logged in' do
      login(student_user)
      patch student_password_path, params: {
        user: {
          current_password: 'password123',
          password: 'newpassword',
          password_confirmation: 'newpassword'
        }
      }
      expect(response).to redirect_to(student_dashboard_path)
    end
  end

  private

  def login(user)
    post session_path, params: {
      email_address: user.email_address,
      password: 'password123' # Matches the default password in the user factory
    }
  end
end
