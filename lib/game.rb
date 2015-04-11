module TeamSchedule

  class Game
    attr_accessor :home_team, :away_team, :kickoff_dt, :location

    def initialize(home_team, away_team, kickoff_dt, location)
      @home_team  = home_team
      @away_team  = away_team
      @kickoff_dt = kickoff_dt
      @location   = location
    end

  end

end
