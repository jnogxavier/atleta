FactoryBot.define do
  factory :notification do
    association :user
    title { Faker::Lorem.sentence(word_count: 3) }
    message { Faker::Lorem.paragraph }
    notification_type { Notification::TYPES.values.sample }
    action_url { "/student/dashboard" }
    read_at { nil }
    metadata { {} }

    trait :read do
      read_at { Time.current - 1.day }
    end

    trait :unread do
      read_at { nil }
    end

    trait :info do
      notification_type { 'info' }
    end

    trait :success do
      notification_type { 'success' }
    end

    trait :warning do
      notification_type { 'warning' }
    end

    trait :error do
      notification_type { 'error' }
    end

    trait :expiration do
      notification_type { 'expiration' }
      title { 'Seu plano está próximo do vencimento' }
      message { 'Seu plano vence em 10 dias. Entre em contato para renovar.' }
    end

    trait :training do
      notification_type { 'training' }
      title { 'Novo treino disponível' }
      message { 'Um novo treino foi atribuído a você. Comece agora!' }
      action_url { '/trainings' }
    end

    trait :anamnese do
      notification_type { 'anamnese' }
      title { 'Atualize sua anamnese' }
      message { 'Por favor, atualize suas informações de anamnese.' }
    end
  end
end
