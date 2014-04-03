class ArtisticScoreCalculator

    def initialize(competition, unicon_scoring = true)
        @competition = competition # should use this some where in the calculations?
        @unicon_scoring = unicon_scoring # should do 'elimination' for each judge_type
    end

    def update_all_places
      @competition.competitors.each do |competitor|
        place(competitor)
      end
    end

    # ####################################################################
    #   BY SCORE (JUDGE)
    # ####################################################################
    # determining the place points for this score (by-judge)
    def new_calc_placing_points(my_place, num_ties)
      total_points = 0
      num_ties.times do
        total_points = total_points + my_place
        my_place = my_place + 1
      end
      (total_points * 1.0) / num_ties
    end

    def calc_placing_points(score)
      @calc_points ||= {}
      unless @calc_points[score.id].nil?
        return @calc_points[score.id]
      end

      my_place = calc_place(score)
      @calc_points[score.id] = new_calc_placing_points(my_place, ties(score))
    end

    def new_ties(score, scores)
      ties = 0
      scores.each do |each_score|
        if each_score == score
          ties = ties + 1
        end
      end
      ties
    end

    def ties(score) # always has '1' tie...with itself
      # XXX refactor this redundant code:
      scores_for_judge = score.judge.get_scores.map { |s| s.total }
      new_ties(score.total, scores_for_judge)
    end

    def new_calc_place(score, scores)
      my_place = 1
      scores.each do |each_score|
        if each_score > score
          my_place = my_place + 1
        end
      end
      my_place
    end

    def calc_place(score)
        @calc_place ||= {}
        unless @calc_place[score.id].nil?
            return @calc_place[score.id]
        end
        unless score.valid?
            return 0
        end

        scores_for_judge = score.judge.get_scores.map { |s| s.total }
        @calc_place[score.id] = new_calc_place(score.total, scores_for_judge)
    end

    # ####################################################################
    #   BY EVENT (all scores, all judges)
    # ####################################################################
    #
    # this should be in "Competitor", but I'm putting here because
    # I don't want to clutter Competitor (which is not always Score-based)
    def new_place(my_points, total_points_per_competitor, my_tie_break_points, tie_break_points_per_competitor)
      my_place = 1
      total_points_per_competitor.each_with_index do |comp_points, index|
        next if comp_points == 0

        if comp_points < my_points
          my_place = my_place + 1
        elsif comp_points == my_points
          if tie_break_points_per_competitor[index] < my_tie_break_points
            my_place = my_place + 1
          end
        end
      end
      if my_points == 0
        my_place = 0
      end
      my_place
    end

    def place(competitor)
      @place ||= {}
      unless @place[competitor.id].nil?
        return @place[competitor.id]
      end

      my_points = total_points(competitor)
      total_points_per_competitor     = competitor.competition.competitors.map { |comp| total_points(comp) }

      jt = JudgeType.find_by_name("Technical") # TODO this should be properly identified
      my_tie_break_points = total_points(competitor, jt)
      tie_break_points_per_competitor = competitor.competition.competitors.map { |comp| total_points(comp, jt) }

      my_place = new_place(my_points, total_points_per_competitor, my_tie_break_points, tie_break_points_per_competitor)

      competitor.place = my_place
      competitor.overall_place = my_place
      @place[competitor.id] = my_place
    end

    def get_placing_points_for_judge_type(competitor, judge_type)
      if judge_type.nil?
        scores = competitor.scores
      else
        scores = competitor.scores.select {|s| judge_type == s.judge.judge_type }
      end
      scores.map {|s| calc_placing_points(s)}
    end

    def total_points(competitor, judge_type = nil)
      # only caching the most common query
      if judge_type.nil?
        @total_points ||= {}
        unless @total_points[competitor.id].nil?
          # Enabling this cache breaks flatland judging...don't know why XXX
          #return @total_points[competitor.id]
        end
      end

      if judge_type.nil?
          total = 0
          competitor.competition.judge_types.uniq.each do |jt|
            total += total_points_for_judge_type(competitor, jt)
          end
      else
          total = total_points_for_judge_type(competitor, judge_type)
      end

      if judge_type.nil?
        @total_points[competitor.id] = total
      else
        total
      end
    end

    def total_points_for_judge_type(competitor, judge_type)
      scores = get_placing_points_for_judge_type(competitor, judge_type)

      unless scores.count > 2
        return 0
      end

      min = lowest_score(competitor, judge_type)
      max = highest_score(competitor, judge_type)

      total_points = scores.reduce(:+) # sum the remaining values

      (total_points - min - max)
    end

=begin
5.10.1 Removing The High And Low
After determining placing points as above, discard the highest and lowest placing score
for each rider. If Rider A has scores of 1,2,1,3,2, take out one of the ones, and the three.
Then Rider A has 1,2,2, for a total of 5. If Rider B has scores of 2,2,2,2,2, he will end
up with 2,2,2, a total of 6. The winner is the competitor with the lowest total placing
points score after the high and low have been removed.

5.10.2 Ties
If more than one competitor has the same placing score after the above process, those
riders will be ranked based on their placing scores for Technical. The scoring process
must be repeated using only the Technical scores for the tied riders to determine this
rank. High and low placing scores are again removed in the process. If competitors’
Technical ranking comes out equal, all competitors with the same score are awarded the
same place.
=end


    def highest_score(competitor, judge_type = nil)
      if @unicon_scoring
        get_placing_points_for_judge_type(competitor, judge_type).max
      else
        # determine the score-to-be-eliminated
        #  and then determine if the chosen judge_type has the first occurrence of that score
        #  and if so, return it, otherwise, don't

        scores = competitor.scores
        placing_points = scores.map {|s| calc_placing_points(s)}
        max = placing_points.max

        if judge_type.nil?
          max
        else
          scores = competitor.scores
          scores.each do |s|
            if calc_placing_points(s) == max
                if judge_type == s.judge.judge_type
                    return max
                else
                    return 0
                end
            end
          end
        end
      end
    end

    def lowest_score(competitor, judge_type = nil)
      if @unicon_scoring
        get_placing_points_for_judge_type(competitor, judge_type).min
      else
        # determine the score-to-be-eliminated
        #  and then determine if the chosen judge_type has the first occurrence of that score
        #  and if so, return it, otherwise, don't
        scores = competitor.scores
        scores = scores.map {|s| calc_placing_points(s)}
        min = scores.min

        if judge_type.nil?
          min
        else
          scores = competitor.scores
          scores.each do |s|
            if calc_placing_points(s) == min
                if judge_type == s.judge.judge_type
                    return min
                else
                    return 0
                end
            end
          end
        end
      end
    end
end
