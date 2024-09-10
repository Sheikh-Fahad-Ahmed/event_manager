puts 'Event Manager Initiated!'

lines = File.readlines('event_attendees.csv')

lines.each do |line|
  puts line
end