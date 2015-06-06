class StreetPointsCalculator
  # Return the numeric place of this score, compared to the results of the other scores by this judge
  # Input: score: the numeric score in question
  # input: all_scores: an array of numeric other results
  #
  # result an integer place
  def judged_place(all_scores, score)
    new_calc_place(score, all_scores)
  end

  # Return the calculated total points for this score
  # which will probably be related to the other scores by this judge
  #
  # returns a numeric (probably afraction)
  def judged_points(all_scores, score)
    convert_place_to_points(judged_place(all_scores, score), ties(all_scores, score))
  end

  private

  def convert_place_to_points(place, ties)
    points = (1..100).to_a # [10, 7, 5, 3, 2, 1]
    PlacingPointsCalculator.new(place, ties).points
  end

  def new_calc_place(score, scores)
    my_place = 1
    scores.each do |each_score|
      if score < each_score
        my_place = my_place + 1
      end
    end
    my_place
  end

  # return the number of scores of this same value from this same judge
  # returns 0 or higher number
  def ties(score_totals, score)
    ties = 0
    score_totals.each do |each_score|
      if each_score == score
        ties = ties + 1
      end
    end
    ties - 1 # eliminate tie-with-self from scores
  end
end