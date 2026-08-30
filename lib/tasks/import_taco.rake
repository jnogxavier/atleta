require "roo"
require "nokogiri"

namespace :taco do
  desc "Import TACO foods table from Excel file"
  task import: :environment do
    file_path = Rails.root.join("db", "Taco-4a-Edicao.xlsx")

    unless File.exist?(file_path)
      puts "Error: File not found at #{file_path}"
      puts "The TACO table is published by NEPA/UNICAMP and is not redistributed"
      puts "with this repository. Download the 4th edition spreadsheet and save it"
      puts "to db/Taco-4a-Edicao.xlsx before running this task."
      exit 1
    end

    puts "Opening Excel file..."
    xlsx = Roo::Spreadsheet.open(file_path.to_s)

    # Get the first sheet
    sheet_name = xlsx.sheets.first
    sheet = xlsx.sheet(sheet_name)

    puts "Found sheet: #{sheet_name}"
    puts "Total rows: #{sheet.last_row}"

    # TACO table has fixed structure:
    # Row 3 contains units (we can skip)
    # Row 4 starts with categories
    # Column 0: Number
    # Column 1: Food description
    # Column 3: Energy (kcal)
    # Column 5: Protein (g)
    # Column 6: Lipídeos/Fat (g)
    # Column 8: Carbohydrate (g)

    name_col = 1
    energy_col = 3
    protein_col = 5
    fat_col = 6
    carb_col = 8
    data_start_row = 4

    puts "Using TACO standard columns:"
    puts "  Name column: #{name_col} (Descrição dos alimentos)"
    puts "  Energy column: #{energy_col} (Energia kcal)"
    puts "  Protein column: #{protein_col} (Proteína g)"
    puts "  Fat column: #{fat_col} (Lipídeos/Gordura g)"
    puts "  Carbohydrate column: #{carb_col} (Carboidrato g)"
    puts "  Data starts at row: #{data_start_row}"

    # Import data
    imported_count = 0
    skipped_count = 0
    errors = []
    current_category = nil
    last_valid_values = { energy: nil, protein: nil, fat: nil, carb: nil }

    puts "\nImporting foods..."

    ActiveRecord::Base.transaction do
      (data_start_row..sheet.last_row).each do |row_num|
      row = sheet.row(row_num)

      # Check if this is a category row (only has data in first column)
      if row[name_col].nil? && row[0].is_a?(String)
        category_name = row[0].strip
        # Skip header rows (Número do, Descrição dos alimentos, etc.)
        if category_name == "Número do" || category_name == "Descrição dos alimentos" || category_name == "Alimento"
          next
        end
        current_category = category_name
        puts "\nCategory: #{current_category}"
        next
      end

      name = row[name_col]&.to_s&.strip
      # Strip HTML tags from food names (e.g., <sup>2</sup>)
      name = Nokogiri::HTML.fragment(name).text if name.present?
      energy = row[energy_col]
      protein = row[protein_col]
      fat = row[fat_col]
      carb = row[carb_col]

      # Skip header rows and empty rows
      if name.blank? || name == "Descrição dos alimentos"
        skipped_count += 1
        next
      end

      # Convert to proper types, handling '*' entries (inherit from previous)
      begin
        # Handle '*' values - they mean "same as entry above"
        # Handle 'NA' values - convert to 0
        energy_str = energy.to_s.strip
        protein_str = protein.to_s.strip
        fat_str = fat.to_s.strip
        carb_str = carb.to_s.strip

        if energy_str == "*"
          energy_val = last_valid_values[:energy]
        elsif energy_str.upcase == "NA" || energy_str.blank?
          energy_val = 0
        else
          energy_val = energy_str.gsub(",", ".").to_f
        end

        if protein_str == "*"
          protein_val = last_valid_values[:protein]
        elsif protein_str.upcase == "NA" || protein_str.blank?
          protein_val = 0
        else
          protein_val = protein_str.gsub(",", ".").to_f
        end

        if fat_str == "*"
          fat_val = last_valid_values[:fat]
        elsif fat_str.upcase == "NA" || fat_str.blank?
          fat_val = 0
        else
          fat_val = fat_str.gsub(",", ".").to_f
        end

        if carb_str == "*"
          carb_val = last_valid_values[:carb]
        elsif carb_str.upcase == "NA" || carb_str.blank?
          carb_val = 0
        else
          carb_val = carb_str.gsub(",", ".").to_f
        end

        # Convert negative values to 0 (rounding errors)
        energy_val = 0 if energy_val.to_f < 0
        protein_val = 0 if protein_val.to_f < 0
        fat_val = 0 if fat_val.to_f < 0
        carb_val = 0 if carb_val.to_f < 0

        # Store last valid values for next '*' entries
        last_valid_values = { energy: energy_val, protein: protein_val, fat: fat_val, carb: carb_val }

        # Find or create, then update with latest values
        Food.find_or_create_by(name: name).update!(
          energy_kcal: energy_val,
          protein_g: protein_val,
          fat_g: fat_val,
          carbohydrate_g: carb_val,
          category: current_category
        )

        imported_count += 1
        print "." if imported_count % 50 == 0
      rescue StandardError => e
        errors << "Row #{row_num}: #{e.message} (#{name})"
        skipped_count += 1
      end
      end
    end

    puts "\n\nImport complete!"
    puts "  Successfully imported: #{imported_count} foods"
    puts "  Skipped: #{skipped_count} rows"

    if errors.any?
      puts "\nErrors encountered:"
      errors.first(10).each { |err| puts "  - #{err}" }
      puts "  ... and #{errors.size - 10} more" if errors.size > 10
    end
  end

  desc "Clear all TACO reference foods"
  task clear: :environment do
    count = Food.count
    used_count = Food.joins(:meal_foods).distinct.count

    puts "Total TACO foods: #{count}"
    puts "Foods currently used in meals: #{used_count}"
    puts "Foods that will be deleted: #{count}"
    puts ""
    print "WARNING: This will delete ALL TACO reference foods, including those used in existing meals. Continue? (yes/no): "
    response = STDIN.gets.chomp

    if response.downcase == "yes"
      Food.destroy_all
      puts "Deleted #{count} TACO reference foods."
    else
      puts "Cancelled."
    end
  end
end
