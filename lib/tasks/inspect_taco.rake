require "roo"

namespace :taco do
  desc "Inspect TACO Excel file structure"
  task inspect: :environment do
    file_path = Rails.root.join("db", "Taco-4a-Edicao.xlsx")

    unless File.exist?(file_path)
      puts "Error: File not found at #{file_path}"
      puts "See lib/tasks/import_taco.rake for where to obtain the spreadsheet."
      exit 1
    end

    puts "Opening file: #{file_path}"
    xlsx = Roo::Spreadsheet.open(file_path.to_s)

    puts "\nAvailable sheets:"
    xlsx.sheets.each_with_index do |sheet_name, idx|
      puts "  #{idx + 1}. #{sheet_name}"
    end

    # Inspect first sheet
    sheet_name = xlsx.sheets.first
    sheet = xlsx.sheet(sheet_name)

    puts "\nFirst sheet: #{sheet_name}"
    puts "Rows: #{sheet.last_row}"
    puts "Columns: #{sheet.last_column}"

    puts "\nFirst 10 rows:"
    (1..[ 10, sheet.last_row ].min).each do |row_num|
      row = sheet.row(row_num)
      puts "\nRow #{row_num}:"
      row.each_with_index do |cell, idx|
        puts "  Col #{idx}: #{cell.inspect}"
      end
    end
  end
end
