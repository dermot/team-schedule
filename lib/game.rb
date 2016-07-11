module TeamSchedule

  class Game
    DEFAULT_DURATION = 100 #90 mins plus 10 for halftime
    DEFAULT_WARMUP_MINS = 30 #Arive x mins before the game
    
    attr_reader :home_team, :away_team, :kickoff_dt, :location,
      :duration_mins, :warmup_mins

    def initialize(home_team, away_team, kickoff_dt, location, args={})
      @home_team  = home_team
      @away_team  = away_team
      @kickoff_dt = kickoff_dt
      @location   = location
      @duration_mins   = args[:duration] || DEFAULT_DURATION
      @warmup_mins   = args[:warmup_mins] || DEFAULT_WARMUP_MINS
    end
 
    def warmup_secs
      warmup_mins * 60
    end

    def duration_secs
      duration_mins * 60
    end


    def summary
      "#{home_team} vs. #{away_team}"
    end
   
    def arrival_dt 
      kickoff_dt - warmup_secs
    end
   
    def end_dt
      kickoff_dt + duration_secs
    end

    def description
      "#{home_team} vs. #{away_team} at #{location}." + 
      "\nKickoff is #{kickoff_dt.strftime('%-l:%M %p')}." +
      "\nArrive #{warmup_mins} minutes early and ready to warm-up."
    end
    
    def uuid
      "#{home_team}_v_#{away_team}@team_schedule".gsub(' ','_')
    end
  
  end
end
