
# 436741

def scan_line(line)
  result = nil
  if match = line.match(/source\":\"(?<type>.+?)\".+event_id\":(?<id>\d+)/)
    source, id = match.captures
    #result = "update events set source = '#{source}' where id = #{id} and source < 'a' and source = integer_value;\n"
    result = "(#{id}, '#{source}'),"
  end
  result
end

File.open('fix_insert.sql', 'w') do |out_file|
  File.open('../../init.log', 'r') do |f|
    n = 0
    f.each_line do |line|
      result = scan_line(line)
      out_file.write(result) if result
      n += 1
      p "#{n}" if n % 1000 == 0
      #break if n > 10
    end
  end
end
