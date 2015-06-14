class FlatlandResultCalculator
  def scoring_description
    "A variation of the Artistic Scoring Class, we calculate last-trick
    scores and follow the rulebook (or do we?)"
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result?
      total_points(competitor)
    end
  end

  # returns the result for this competitor
  def competitor_comparable_result(competitor)
    if competitor.has_result?
      total_points(competitor)
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(competitor)
    total_last_trick_points(competitor)
  end

  private

  # Return the resulting score for this competitor
  # after having eliminated the highest and lowest total score
  # Note: There is only 1 judge-type for flatland
  def total_points(competitor)
    scores = competitor.scores.map(&:total)

    if scores.count <= 2
      return 0
    end

    min = scores.min
    max = scores.max

    total_points = scores.reduce(:+) # sum the remaining values

    total_points - min - max
  end

  # the last_trick points are stored in val_4
  # This also eliminates the high and low Score object (based on its total score)
  # In order to compare the 'last_trick' of those judges which were originally used to
  # actually tie the competitors
  def total_last_trick_points(competitor)
    scores = competitor.scores

    if scores.count <= 2
      return 0
    end

    totals = scores.map(&:total)

    # choose a 'score' object which is going to be removed
    #  because it's the 'max' and 'min' object(s)
    max = scores.find {|s| s.total == totals.max }.val_4
    min = scores.find {|s| s.total == totals.min }.val_4

    last_trick_scores = scores.map {|s| s.val_4.to_i}
    total = last_trick_scores.reduce(:+) || 0

    total - max - min
  end
end