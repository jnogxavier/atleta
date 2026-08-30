puts "🏋️ Seeding exercises..."

# Strength Exercises
strength_exercises = [
  { name: 'Supino Reto', muscle_group: 'Peito', equipment: 'Barra', description: 'Exercício básico para desenvolvimento do peitoral' },
  { name: 'Supino Inclinado', muscle_group: 'Peito', equipment: 'Barra', description: 'Foca na parte superior do peito' },
  { name: 'Crucifixo com Halteres', muscle_group: 'Peito', equipment: 'Halteres', description: 'Isolamento do peitoral' },
  { name: 'Agachamento Livre', muscle_group: 'Pernas', equipment: 'Barra', description: 'Exercício fundamental para pernas' },
  { name: 'Leg Press 45°', muscle_group: 'Pernas', equipment: 'Máquina', description: 'Alternativa ao agachamento' },
  { name: 'Cadeira Extensora', muscle_group: 'Quadríceps', equipment: 'Máquina', description: 'Isolamento de quadríceps' },
  { name: 'Mesa Flexora', muscle_group: 'Posterior de Coxa', equipment: 'Máquina', description: 'Trabalha posterior de coxa' },
  { name: 'Stiff', muscle_group: 'Posterior de Coxa', equipment: 'Barra', description: 'Fortalecimento de posterior' },
  { name: 'Levantamento Terra', muscle_group: 'Costas', equipment: 'Barra', description: 'Exercício composto para costas' },
  { name: 'Puxada Alta', muscle_group: 'Costas', equipment: 'Cabo', description: 'Desenvolvimento do dorsal' },
  { name: 'Remada Curvada', muscle_group: 'Costas', equipment: 'Barra', description: 'Espessura das costas' },
  { name: 'Remada Cavalinho', muscle_group: 'Costas', equipment: 'Cabo', description: 'Trabalha toda a região dorsal' },
  { name: 'Desenvolvimento Militar', muscle_group: 'Ombros', equipment: 'Barra', description: 'Ombros completos' },
  { name: 'Elevação Lateral', muscle_group: 'Ombros', equipment: 'Halteres', description: 'Deltoide lateral' },
  { name: 'Elevação Frontal', muscle_group: 'Ombros', equipment: 'Halteres', description: 'Deltoide anterior' },
  { name: 'Rosca Direta', muscle_group: 'Bíceps', equipment: 'Barra', description: 'Exercício clássico de bíceps' },
  { name: 'Rosca Alternada', muscle_group: 'Bíceps', equipment: 'Halteres', description: 'Trabalho unilateral de bíceps' },
  { name: 'Rosca Martelo', muscle_group: 'Bíceps', equipment: 'Halteres', description: 'Foco em braquial' },
  { name: 'Tríceps Testa', muscle_group: 'Tríceps', equipment: 'Barra', description: 'Isolamento de tríceps' },
  { name: 'Tríceps Corda', muscle_group: 'Tríceps', equipment: 'Cabo', description: 'Tríceps na polia' },
  { name: 'Mergulho em Paralelas', muscle_group: 'Tríceps', equipment: 'Peso Corporal', description: 'Exercício composto' },
  { name: 'Panturrilha no Leg Press', muscle_group: 'Panturrilha', equipment: 'Máquina', description: 'Desenvolvimento de panturrilha' },
  { name: 'Panturrilha em Pé', muscle_group: 'Panturrilha', equipment: 'Máquina', description: 'Foco em gastrocnêmio' },
  { name: 'Agachamento Sumô', muscle_group: 'Pernas', equipment: 'Barra', description: 'Trabalha interno de coxa' },
  { name: 'Afundo', muscle_group: 'Pernas', equipment: 'Halteres', description: 'Exercício unilateral' }
]

strength_exercises.each do |exercise|
  ex = StrengthExercise.find_or_create_by(name: exercise[:name]) do |e|
    e.muscle_group = exercise[:muscle_group]
    e.equipment = exercise[:equipment]
    e.description = exercise[:description]
  end

  # Add instructional video if not exists
  if ex.videos.empty? && exercise[:name] == 'Supino Reto'
    ex.videos.create!(
      title: 'Como executar o Supino Reto corretamente',
      category: 'Técnica',
      url: 'https://www.youtube.com/watch?v=rT7DgCr-3pg',
      duration: '8:30',
      description: 'Aprenda a técnica correta do supino reto para maximizar ganhos e evitar lesões'
    )
  elsif ex.videos.empty? && exercise[:name] == 'Agachamento Livre'
    ex.videos.create!(
      title: 'Técnica perfeita do Agachamento Livre',
      category: 'Técnica',
      url: 'https://www.youtube.com/watch?v=ultWZbUMPL8',
      duration: '10:15',
      description: 'Domine o agachamento livre com esta demonstração completa'
    )
  end
end

puts "✅ Created #{StrengthExercise.count} strength exercises"

# Mobility Exercises
mobility_exercises = [
  { name: 'Alongamento de Ombros', description: 'Melhora mobilidade dos ombros' },
  { name: 'Alongamento de Quadril', description: 'Abertura de quadril' },
  { name: 'Cat-Cow', description: 'Mobilidade de coluna' },
  { name: 'World\'s Greatest Stretch', description: 'Alongamento completo' },
  { name: 'Rotação de Tornozelo', description: 'Mobilidade de tornozelo' },
  { name: 'Alongamento de Posterior', description: 'Flexibilidade posterior' },
  { name: 'Passagem de Bastão', description: 'Mobilidade de ombro' },
  { name: 'Deep Squat Hold', description: 'Posição de agachamento profundo' },
  { name: 'Rotação Torácica', description: 'Mobilidade de tórax' },
  { name: 'Hip Flexor Stretch', description: 'Alongamento de flexores de quadril' }
]

mobility_exercises.each do |exercise|
  MobilityExercise.find_or_create_by(name: exercise[:name]) do |ex|
    ex.description = exercise[:description]
  end
end

puts "✅ Created #{MobilityExercise.count} mobility exercises"

# Core Exercises
core_exercises = [
  { name: 'Prancha Frontal', description: 'Isometria de core' },
  { name: 'Prancha Lateral', description: 'Trabalha oblíquos' },
  { name: 'Abdominal Supra', description: 'Porção superior do abdômen' },
  { name: 'Abdominal Infra', description: 'Porção inferior do abdômen' },
  { name: 'Russian Twist', description: 'Rotação de tronco' },
  { name: 'Mountain Climbers', description: 'Core dinâmico' },
  { name: 'Hollow Hold', description: 'Isometria avançada' },
  { name: 'Dead Bug', description: 'Estabilização de core' },
  { name: 'Bird Dog', description: 'Equilíbrio e core' },
  { name: 'Bicycle Crunch', description: 'Trabalho de oblíquos' }
]

core_exercises.each do |exercise|
  CoreExercise.find_or_create_by(name: exercise[:name]) do |ex|
    ex.description = exercise[:description]
  end
end

puts "✅ Created #{CoreExercise.count} core exercises"

# Cardio Exercises
cardio_exercises = [
  { name: 'Corrida', equipment: 'Esteira', description: 'Cardio tradicional' },
  { name: 'Bicicleta Ergométrica', equipment: 'Bicicleta', description: 'Baixo impacto' },
  { name: 'Elíptico', equipment: 'Elíptico', description: 'Cardio de baixo impacto' },
  { name: 'Remo', equipment: 'Remo Ergométrico', description: 'Cardio corpo inteiro' },
  { name: 'Burpees', equipment: 'Peso Corporal', description: 'HIIT intenso' },
  { name: 'Jumping Jacks', equipment: 'Peso Corporal', description: 'Aquecimento cardiovascular' },
  { name: 'Pular Corda', equipment: 'Corda', description: 'Cardio de alta intensidade' },
  { name: 'Sprint Intervals', equipment: 'Esteira', description: 'Treino intervalado' },
  { name: 'Step Up', equipment: 'Step', description: 'Cardio com resistência' },
  { name: 'Battle Ropes', equipment: 'Cordas', description: 'HIIT para braços' }
]

cardio_exercises.each do |exercise|
  CardioExercise.find_or_create_by(name: exercise[:name]) do |ex|
    ex.equipment = exercise[:equipment]
    ex.description = exercise[:description]
  end
end

puts "✅ Created #{CardioExercise.count} cardio exercises"

puts "🎉 Exercise seeding completed!"
puts "   - Strength: #{StrengthExercise.count}"
puts "   - Mobility: #{MobilityExercise.count}"
puts "   - Core: #{CoreExercise.count}"
puts "   - Cardio: #{CardioExercise.count}"
