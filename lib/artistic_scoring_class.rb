class ArtisticScoringClass < BaseScoringClass

  # This is used temporarily to access the calculator, but will likely be private-ized soon
  def score_calculator
    unicon_scoring = !EventConfiguration.artistic_score_elimination_mode_naucc
    ArtisticScoreCalculator.new(@competition, unicon_scoring)
  end

  # describes how to label the results of this competition
  def result_description
    nil
  end

  def render_path
    "freestyle_scores"
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.scores.count > 0
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if self.competitor_has_result?(competitor)
      nil# not applicable in Freestyle
    else
      nil
    end
  end

  def competitor_dq?(competitor)
    false
  end

  # Function which places all of the competitors in the competition
  def place_all
    nil
  end


  # Used when trying to destroy all results for a competition
  def all_competitor_results
    nil
  end

  def results_importable
    false
  end

  def uses_judges
    true
  end

  def include_event_name
    true
  end
end
