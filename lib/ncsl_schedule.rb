require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'ri_cal'
require 'yaml'
require_relative 'game.rb'

module NCSLSchedule

    class Team
      DEF_EARTLY_ARRV_MINS = 40

      attr_reader :name, :age, :schedule_url, :games, :early_arrival_mins

      def initialize(name, age, schedule_url, early_arrival_mins =  nil)
        @name = name 
        @age = age
        @schedule_url = schedule_url
        @early_arrival_mins = early_arrival_mins || DEF_EARTLY_ARRV_MINS
        @games = []
        load_games
      end
      
      def schedule(format = 'ics')
        case format
        when 'ics'
          cal = RiCal.Calendar do |cal|
            @games.each do |game|
              cal.event do |event|
                event.summary = "#{game.home_team} vs. #{game.away_team}"
                event.dtstart = game.kickoff_dt - (early_arrival_mins * 60)
                event.dtend = game.kickoff_dt + (75 * 60)
                event.location = game.location
                event.description = "#{game.home_team} vs. #{game.away_team} " + 
                                    " at #{game.location}." + 
                                    "\n Kickoff is #{game.kickoff_dt.strftime('%-l:%M %p')}." +
                                    "\nArrive #{early_arrival_mins} minutes early and ready to warm-up."
                event.uid = "#{game.home_team}#{game.kickoff_dt.to_i}@tullinahoo.com".gsub(' ','-')
              end
            end
          cal.to_s
          end
        else
          raise 'format not supported'
        end
      end

      def schedule_doc(schedule_url)
        Nokogiri::HTML(open(schedule_url))
      end

      def load_games
        doc = schedule_doc(@schedule_url)
        game_rows = doc.css('[class~="GameRow"]')
        game_rows.each do |row|
          home_team =  row.css('[class~="tm1"]').text.chomp.gsub(/  /,'')
          away_team =  row.css('[class~="tm2"]').text.chomp.gsub(/  /,'')
          date =  row.css('[class~="date"]').text.chomp
          time =  row.css('[class~="time"]').text.chomp
          kickoff_dt =  Time.parse("#{date} #{time}")
          location =  row.css('[class~="facility"]').css('a').text.gsub(/  /,'')
          @games << Game.new(home_team, away_team, kickoff_dt, location)
        end
      end 
    end

end
