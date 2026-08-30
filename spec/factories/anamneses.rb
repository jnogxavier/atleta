FactoryBot.define do
  factory :anamnese do
    association :user

    # Required basic fields
    gender { %w[male female].sample }
    age { Faker::Number.between(from: 18, to: 80) }
    height { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    weight { Faker::Number.decimal(l_digits: 2, r_digits: 1) }
    goal { Faker::Lorem.sentence }
    physical_activity_level { %w[sedentary light moderate active very_active].sample }

    # Required personal information - VALID CPF (using a known valid one)
    # 11144477735 is a valid test CPF
    cpf { "11144477735" }
    address { Faker::Address.full_address }

    # Sleep and routine (required)
    sleep_hours { Faker::Number.between(from: 4, to: 12) }
    profession { Faker::Job.title }
    training_availability { %w[morning afternoon evening night flexible].sample }
    wake_up_time { "06:00" }
    sleep_time { "22:00" }
    time_of_biggest_appetite { %w[morning afternoon evening night].sample }
    alcohol_consumption { %w[never rarely occasionally frequently].sample }
    smoking { [ true, false ].sample }
    bowel_movement_scale { Faker::Number.between(from: 1, to: 7).to_s }
    urine_scale { Faker::Number.between(from: 1, to: 8).to_s }

    # Training (required)
    training_location { %w[home gym outdoor].sample }
    available_equipment { Faker::Lorem.paragraph }

    # Meal schedule (required)
    breakfast { Faker::Food.dish }
    lunch { Faker::Food.dish }
    afternoon_snack { Faker::Food.dish }
    dinner { Faker::Food.dish }

    # Digestion & Health (required)
    digestion { %w[excellent good fair poor].sample }
    chewing { %w[slow normal fast].sample }
    heartburn { [ true, false ].sample }
    reflux { [ true, false ].sample }
    gastritis { [ true, false ].sample }

    # Eating habits (required)
    eating_motivation { Faker::Lorem.paragraph }
    personality { Faker::Lorem.paragraph }
    snacks_between_meals { [ true, false ].sample }
    satisfied_with_meals { %w[always usually sometimes rarely never].sample }

    # REQUIRED: Either routine_description OR audio - adding routine_description
    routine_description { "Rotina de exercícios e alimentação" }

    # Optional fields - VALID Brazilian phone (São Paulo area code 11, 9XXXXX-XXXX format)
    phone { "(11) 98765-4321" }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 80) }
    marital_status { %w[single married divorced widowed].sample }
    health_conditions { Faker::Lorem.paragraph }
    medications { Faker::Lorem.paragraph }
    injuries { Faker::Lorem.paragraph }
    dietary_restrictions { Faker::Lorem.sentence }
    stress_level { %w[low moderate high].sample }
    expectations { Faker::Lorem.paragraph }
    breakfast_time { "07:00" }
    lunch_time { "12:00" }
    afternoon_snack_time { "15:00" }
    dinner_time { "19:00" }

    trait :minimal do
      health_conditions { nil }
      medications { nil }
      injuries { nil }
      dietary_restrictions { nil }
      phone { "(11) 98765-4321" } # Required field
      birth_date { nil }
      marital_status { nil }
      expectations { nil }
      stress_level { "moderate" } # Required field
      breakfast_time { "07:00" } # Required field
      lunch_time { "12:00" } # Required field
      afternoon_snack_time { "15:00" } # Required field
      dinner_time { "19:00" } # Required field
    end

    trait :male do
      gender { "male" }
    end

    trait :female do
      gender { "female" }
    end

    trait :with_health_issues do
      health_conditions { "Diabetes, High blood pressure" }
      medications { "Metformin, Lisinopril" }
      injuries { "Previous knee surgery" }
      dietary_restrictions { "Gluten-free" }
    end
  end
end
