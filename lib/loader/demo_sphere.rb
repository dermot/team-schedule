module TeamSchedule
  module Loader
    module DemoSphere

      def schedule_doc(schedule_url)
        Nokogiri::HTML(open(schedule_url))
      end

      def load_games(game_klass = Game)
        doc = schedule_doc(@schedule_url)
        game_rows = doc.css('[class~="GameRow"]')
        game_rows.each do |row|
          home_team =  row.css('[class~="tm1"]').text.chomp.gsub(/  /,'')
          away_team =  row.css('[class~="tm2"]').text.chomp.gsub(/  /,'')
          date =  row.css('[class~="date"]').text.chomp
          time =  row.css('[class~="time"]').text.chomp
          kickoff_dt =  Time.parse("#{date} #{time}")
          location =  row.css('[class~="facility"]').css('a').text.gsub(/  /,'')
          @games << game_klass.new(home_team, away_team, kickoff_dt, location)
        end
      end 

    end
  end
end
