require "rails_helper"

# Covers the multi-step signup journey handled by RegistrationsController:
#   new -> update_personal_data -> update_anamnese -> finalize
# plus the JS-less `create` path that captures a PendingRegistration.
RSpec.describe "Registrations", type: :request do
  # A complete, valid anamnese payload. eating_motivation must be an array
  # because RegistrationService#save_anamnese permits it as `eating_motivation: []`
  # and joins the values into a pipe-delimited string.
  def valid_anamnese_attributes
    {
      gender: "male",
      age: 30,
      height: "1.80",
      weight: "80.0",
      goal: "Ganhar massa muscular",
      physical_activity_level: "moderate",
      profession: "Engenheiro",
      training_availability: "morning",
      training_location: "gym",
      available_equipment: "Halteres e barra",
      sleep_hours: 8,
      wake_up_time: "06:00",
      sleep_time: "22:00",
      time_of_biggest_appetite: "afternoon",
      alcohol_consumption: "never",
      stress_level: "low",
      breakfast: "Ovos mexidos",
      lunch: "Frango com arroz",
      afternoon_snack: "Fruta",
      dinner: "Salada com peixe",
      breakfast_time: "07:00",
      lunch_time: "12:00",
      afternoon_snack_time: "15:00",
      dinner_time: "19:00",
      digestion: "good",
      chewing: "normal",
      eating_motivation: [ "Fome" ],
      personality: "Calmo e disciplinado",
      satisfied_with_meals: "usually",
      bowel_movement_scale: "4",
      urine_scale: "3",
      cpf: "11144477735",
      phone: "(11) 98765-4321",
      address: "Rua das Flores, 123",
      smoking: false,
      heartburn: false,
      reflux: false,
      gastritis: false,
      snacks_between_meals: false,
      routine_description: "Rotina de treino e alimentacao regular"
    }
  end

  describe "GET /signup" do
    it "renders the registration form" do
      get new_registration_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "the multi-step signup flow (happy path)" do
    it "creates a draft, saves anamnese, finalizes and logs the student in" do
      # Step 1: personal data -> creates a draft user, stores draft_user_id in session
      patch update_personal_data_registration_path, params: {
        user: {
          name: "Novo Aluno",
          email_address: "novo.aluno@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["success"]).to be(true)
      user_id = body["user_id"]
      expect(user_id).to be_present

      user = User.find(user_id)
      expect(user.registration_status).to eq("draft")
      expect(user.role).to eq("student")

      # Step 2: anamnese (relies on session[:draft_user_id] from step 1)
      patch update_anamnese_registration_path, params: {
        user: { anamnese_attributes: valid_anamnese_attributes }
      }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["success"]).to be(true)
      expect(user.reload.anamnese).to be_present

      # Step 3: finalize -> completes registration, creates profile + pending record
      expect {
        patch finalize_registration_path
      }.to change(StudentProfile, :count).by(1)
        .and change { PendingRegistration.where(email: "novo.aluno@example.com").count }.by(1)

      expect(response).to have_http_status(:ok)
      finalize_body = JSON.parse(response.body)
      expect(finalize_body["success"]).to be(true)
      expect(finalize_body["redirect_url"]).to eq(student_dashboard_path)

      expect(user.reload.registration_status).to eq("complete")
      expect(user.terms_accepted).to be(true)
      expect(user.student_profile).to be_present

      # Session is now authenticated: an authenticated-only page is reachable.
      get student_dashboard_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "validation-failure paths" do
    it "rejects a too-short password on the personal-data step" do
      expect {
        patch update_personal_data_registration_path, params: {
          user: {
            name: "Aluno",
            email_address: "curto@example.com",
            password: "short",
            password_confirmation: "short"
          }
        }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["success"]).to be(false)
      expect(body["errors"]).to include("Senha deve ter no mínimo 8 caracteres")
    end

    it "rejects finalize when there is no active registration session" do
      patch finalize_registration_path
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["success"]).to be(false)
    end
  end

  describe "POST /signup (JS-less create path)" do
    it "captures a pending registration and redirects home" do
      expect {
        post registration_path, params: {
          user: {
            name: "Jane Doe",
            email_address: "jane.doe@example.com",
            password: "password123",
            password_confirmation: "password123",
            anamnese_attributes: { phone: "(11) 91234-5678" }
          }
        }
      }.to change(PendingRegistration, :count).by(1)

      expect(response).to redirect_to(root_path)
      pending = PendingRegistration.find_by(email: "jane.doe@example.com")
      expect(pending).to be_present
      expect(pending.phone).to eq("(11) 91234-5678")
    end
  end
end
