require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'





count_hour = Hash.new(0)

def clena_zipcode(zipcode)
  zipcode.to_s.rjust(5,'0')[0..4]
end

def clean_number(number)
  number = number.gsub(/\D/, "")
  return 'Bad Number' if number.nil?
  return 'Bad Number' if number.length < 10 || number.length > 11
  return number if number.length == 10
  return number.slice(1..-1) if number.length == 11 && number.start_with?('1')
end

def frequent_hours
  peak_hour = hour_count.max_by {|hour, count| count}
  peak_hour[0]
end

def get_hour(date_time)
  formatted_date = DateTime.strptime(date_time,'%m/%d/%y %H:%M')
  hour = formatted_date.hour
  hour
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end


puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter


contents.each do |row|
  name = row[:first_name]
  zipcode = clena_zipcode(row[:zipcode])
  phone_number = clean_number(row[:homephone])
  hour = get_hour(row[:regdate])
  count_hour[hour] += 1

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end

peak_hour = count_hour.max_by {|hour,count| count}
puts "Frequent hour #{peak_hour[0]}"