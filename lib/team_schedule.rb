require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'icalendar'
require 'icalendar/tzinfo'
require 'yaml'
require_relative 'game.rb'
require_relative 'loader.rb'

module TeamSchedule

  class Team
    
    WARMUP_MINS = 40 # How early to arrive for warmups, etc...
    GAME_DURATION_MINS = 100 # Two 45 min halfs with 10 mins for halftime

    attr_reader :name, :age, :schedule_type, :schedule_url, :games, 
      :warmup_secs, :game_duration_secs

    def initialize(name, age, schedule_url, args = {}) 
      @name = name 
      @age = age
      @schedule_url = schedule_url
      @warmup_secs = ( args[:warmup_mins] || WARMUP_MINS ) * 60
      @game_duration_secs = ( args[:game_duration_mins] || GAME_DURATION_MINS ) * 60
      @games = []
      register_loader(args[:schedule_type] || 'DemoSphere')
      load_games
    end

    def register_loader(schedule_type)
      case schedule_type 
      when 'DemoSphere'
        extend Loader::DemoSphere
      else
        raise "Unknown schedule_type : #{schedule_type}"
      end 
    end 
    
    def schedule(format = 'ics')
      case format
      when 'ics'
        build_icalendar
      when /txt|text/
        build_txt_cal
      else
        raise 'format not supported'
      end
    end
    
    def build_txt_cal
      cal = ""
      @games.each do |game|
       cal <<  "\n########## #{game.summary} ###########\n" +
       "start: #{game.arrival_dt}\n" +
       "end: #{game.end_dt}\n" +
       "location: #{game.location}\n" +
       "description: #{game.description}\n" + 
       "uid: #{game.uuid}" +
       "\n" * 2
      end
      cal.to_s
    end

    def build_icalendar
      cal = Icalendar::Calendar.new
      @games.each do |game|
        cal.event do |e|
          e.summary = game.summary 
          e.dtstart = Icalendar::Values::DateTime.new game.arrival_dt.utc, 'tzid' => 'UTC'
          e.dtend  = Icalendar::Values::DateTime.new game.end_dt.utc, 'tzid' => 'UTC'
          e.location =  game.location
          e.description = game.description 
          e.uid  = game.uuid
        end
      end
      cal
    end

  end

end

