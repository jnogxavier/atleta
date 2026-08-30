# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database for Atleta Portal..."

# Create admin user
admin = User.find_or_initialize_by(email_address: "admin@example.com")
if admin.new_record?
  admin.name = "Administrator"
  admin.password = "admin123"
  admin.password_confirmation = "admin123"
  admin.role = :admin
  admin.terms_accepted = true
  admin.save!
  puts "✅ Admin user created: admin@example.com / admin123"
else
  puts "ℹ️  Admin user already exists"
end

# Create student user with profile
student = User.find_or_initialize_by(email_address: "aluno@example.com")
if student.new_record?
  student.name = "João Silva"
  student.password = "aluno123"
  student.password_confirmation = "aluno123"
  student.role = :student
  student.terms_accepted = true
  student.save!

  StudentProfile.create!(
    user: student,
    name: "João Silva",
    student_id: "ALU001",
    plan: "Transformação Completa",
    expires_at: 6.months.from_now,
    status: "active"
  )

  puts "✅ Student user created: aluno@example.com / aluno123"
else
  puts "ℹ️  Student user already exists"
end

# Create partner user with profile
partner = User.find_or_initialize_by(email_address: "parceiro@example.com")
if partner.new_record?
  partner.name = "Maria Oliveira"
  partner.password = "parceiro123"
  partner.password_confirmation = "parceiro123"
  partner.role = :partner
  partner.terms_accepted = true
  partner.save!

  PartnerProfile.create!(
    user: partner,
    name: "Maria Oliveira",
    partner_id: "PAR001",
    profession: "Nutricionista",
    specialty: "Nutrição Esportiva",
    status: "active"
  )

  puts "✅ Partner user created: parceiro@example.com / parceiro123"
else
  puts "ℹ️  Partner user already exists"
end

# Seed Exercise Library
puts "\n📚 Creating exercise library..."

# Strength Exercises
strength_exercises_data = [
  { name: "Agachamento Livre", muscle_group: "Pernas", equipment: "Barra", video_url: "https://www.youtube.com/watch?v=ultWZbUMPL8", description: "Exercício fundamental para desenvolvimento de pernas" },
  { name: "Supino Reto", muscle_group: "Peito", equipment: "Barra", video_url: "https://www.youtube.com/watch?v=rT7DgCr-3pg", description: "Exercício principal para peito" },
  { name: "Levantamento Terra", muscle_group: "Costas/Posterior", equipment: "Barra", video_url: "https://www.youtube.com/watch?v=op9kVnSso6Q", description: "Exercício composto fundamental" },
  { name: "Desenvolvimento Militar", muscle_group: "Ombros", equipment: "Barra", video_url: "https://www.youtube.com/watch?v=2yjwXTZQDDI", description: "Desenvolvimento de ombros com barra" },
  { name: "Remada Curvada", muscle_group: "Costas", equipment: "Barra", video_url: "https://www.youtube.com/watch?v=T3N-TO4reLQ", description: "Exercício para desenvolvimento das costas" },
  { name: "Rosca Direta", muscle_group: "Bíceps", equipment: "Barra", video_url: "https://www.youtube.com/watch?v=kwG2ipFRgfo", description: "Exercício isolado para bíceps" },
  { name: "Tríceps Testa", muscle_group: "Tríceps", equipment: "Barra", video_url: "https://www.youtube.com/watch?v=d_KZxkY_0cM", description: "Exercício isolado para tríceps" },
  { name: "Leg Press", muscle_group: "Pernas", equipment: "Máquina", video_url: "https://www.youtube.com/watch?v=IZxyjW7MPJQ", description: "Exercício de empurrar com as pernas" }
]

strength_exercises_data.each do |data|
  StrengthExercise.find_or_create_by!(name: data[:name]) do |exercise|
    exercise.attributes = data
  end
end
puts "✅ #{StrengthExercise.count} strength exercises created"

# Mobility Exercises
mobility_exercises_data = [
  { name: "Cat-Cow", region: "Coluna", video_url: "https://www.youtube.com/watch?v=kqnua4rHVVA", description: "Mobilidade da coluna vertebral" },
  { name: "90/90 Hip Stretch", region: "Quadril", video_url: "https://www.youtube.com/watch?v=8p6FtlqpAYg", description: "Mobilidade de quadril" },
  { name: "World's Greatest Stretch", region: "Corpo todo", video_url: "https://www.youtube.com/watch?v=TLckV3S51Mg", description: "Alongamento dinâmico completo" },
  { name: "Thoracic Rotation", region: "Coluna torácica", video_url: "https://www.youtube.com/watch?v=yLxO1NZLhlk", description: "Rotação torácica" },
  { name: "Hip Flexor Stretch", region: "Quadril", video_url: "https://www.youtube.com/watch?v=YQmpO9VT2X4", description: "Alongamento de flexores do quadril" }
]

mobility_exercises_data.each do |data|
  MobilityExercise.find_or_create_by!(name: data[:name]) do |exercise|
    exercise.attributes = data
  end
end
puts "✅ #{MobilityExercise.count} mobility exercises created"

# Core Exercises
core_exercises_data = [
  { name: "Prancha", category: "Isométrico", video_url: "https://www.youtube.com/watch?v=ASdvN_XEl_c", description: "Exercício isométrico de core" },
  { name: "Dead Bug", category: "Estabilização", video_url: "https://www.youtube.com/watch?v=g_BYB0R-4Ws", description: "Exercício de estabilização do core" },
  { name: "Pallof Press", category: "Anti-rotação", video_url: "https://www.youtube.com/watch?v=AClLnaApPjs", description: "Exercício anti-rotacional" },
  { name: "Bird Dog", category: "Estabilização", video_url: "https://www.youtube.com/watch?v=wiFNA3sqjCA", description: "Estabilização e equilíbrio" },
  { name: "Russian Twist", category: "Rotação", video_url: "https://www.youtube.com/watch?v=wkD8rjkodUI", description: "Exercício rotacional para oblíquos" }
]

core_exercises_data.each do |data|
  CoreExercise.find_or_create_by!(name: data[:name]) do |exercise|
    exercise.attributes = data
  end
end
puts "✅ #{CoreExercise.count} core exercises created"

# Cardio Exercises
cardio_exercises_data = [
  { name: "Corrida", cardio_type: "Corrida", video_url: "https://www.youtube.com/watch?v=br1ja7dZUFA", description: "Corrida em ritmo moderado" },
  { name: "Bicicleta", cardio_type: "Ciclismo", video_url: "https://www.youtube.com/watch?v=SYzpOJufWq8", description: "Pedalar em ritmo constante" },
  { name: "Pular Corda", cardio_type: "Saltos", video_url: "https://www.youtube.com/watch?v=FJmRQ5iTXKE", description: "Pular corda intervalado" },
  { name: "Burpees", cardio_type: "HIIT", video_url: "https://www.youtube.com/watch?v=TU8QYVW0gDU", description: "Exercício de corpo inteiro" },
  { name: "Remo", cardio_type: "Remo", video_url: "https://www.youtube.com/watch?v=zQ82RYIFLN8", description: "Remo ergômetro" }
]

cardio_exercises_data.each do |data|
  CardioExercise.find_or_create_by!(name: data[:name]) do |exercise|
    exercise.cardio_type = data[:cardio_type]
    exercise.video_url = data[:video_url]
    exercise.description = data[:description]
  end
end
puts "✅ #{CardioExercise.count} cardio exercises created"

# Create sample training for the student
if student.student_profile && Training.where(student_profile: student.student_profile).empty?
  puts "\n💪 Creating sample training..."

  training = Training.create!(
    student_profile: student.student_profile,
    name: "Treino A - Peito e Tríceps",
    day: "Segunda e Quinta",
    active: true,
    description: "Treino focado em peito e tríceps"
  )

  # Add strength exercises to training
  TrainingStrengthExercise.create!(
    training: training,
    strength_exercise: StrengthExercise.find_by(name: "Supino Reto"),
    sets: 4,
    reps: 8,
    rest: 90,
    position: 1,
    notes: "Manter escápulas retraídas"
  )

  TrainingStrengthExercise.create!(
    training: training,
    strength_exercise: StrengthExercise.find_by(name: "Tríceps Testa"),
    sets: 3,
    reps: 12,
    rest: 60,
    position: 2
  )

  # Add mobility exercises
  TrainingMobilityExercise.create!(
    training: training,
    mobility_exercise: MobilityExercise.find_by(name: "Cat-Cow"),
    sets: 2,
    duration: 30,
    position: 1,
    notes: "Fazer no aquecimento"
  )

  # Add core exercises
  TrainingCoreExercise.create!(
    training: training,
    core_exercise: CoreExercise.find_by(name: "Prancha"),
    sets: 3,
    rest: 45,
    position: 1,
    notes: "Segurar 30-60 segundos por série"
  )

  # Add cardio
  TrainingCardioExercise.create!(
    training: training,
    cardio_exercise: CardioExercise.find_by(name: "Pular Corda"),
    duration: 10,
    intensity: "moderate",
    calories: 100,
    position: 1,
    notes: "Aquecimento inicial"
  )

  puts "✅ Sample training created for student"
end

puts "\n🎉 Database seeded successfully!"
puts "\n📝 Test accounts:"
puts "   Admin:    admin@example.com / admin123"
puts "   Aluno:    aluno@example.com / aluno123"
puts "   Parceiro: parceiro@example.com / parceiro123"
