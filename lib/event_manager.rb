require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

template_letter = File.read('form_letter.html')
civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = File.read('./secret.key').strip

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislator_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read('./secret.key').strip

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = legislators.officials
    legislator_name = legislators.map(&:name)
    legislator_string = legislator_name.join(', ')
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

puts "EventManager Initialized!"

contents = CSV.open(
  'event_attendees.csv', 
  headers: true, 
  header_converters: :symbol)

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislator_by_zipcode(zipcode)

  personal_letter = template_letter.gsub('FRIST_NAME', name)
  personal_letter.gsub!('LEGISLATORS',legislators)

  puts personal_letter
  

  puts "#{name} #{zipcode} #{legislators}"
end