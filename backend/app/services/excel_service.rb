require 'roo'

class ExcelService
  def self.parse_students(file_path)
    spreadsheet = open_spreadsheet(file_path)
    header = spreadsheet.row(1).map { |h| h.to_s.strip.downcase.underscore }
    rows = []

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      next if row['name'].blank? || row['nis'].blank?
      rows << row
    end

    rows
  end

  def self.parse_questions(file_path)
    spreadsheet = open_spreadsheet(file_path)
    header = spreadsheet.row(1).map { |h| h.to_s.strip.downcase.underscore }
    rows = []

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      next if row['question_text'].blank?
      rows << row
    end

    rows
  end

  private

  def self.open_spreadsheet(file_path)
    ext = File.extname(file_path).downcase
    case ext
    when '.xlsx'
      Roo::Excelx.new(file_path)
    when '.xls'
      Roo::Excel.new(file_path)
    when '.csv'
      Roo::CSV.new(file_path)
    else
      raise "Unsupported file format: #{ext}. Please upload .xlsx, .xls, or .csv"
    end
  end
end
