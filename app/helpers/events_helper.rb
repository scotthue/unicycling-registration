module EventsHelper
    def scoring_link(judge)
        class_name = judge.competition.event.event_class

        if class_name == 'Two Attempt Distance'
            link_to judge.judge_type.name, competition_distance_attempts_path(judge.competition) 
        elsif class_name == 'Freestyle'
            link_to judge.judge_type.name, competition_competitors_path(judge.competition)
        elsif class_name == 'Flatland'
            link_to judge.judge_type.name, competition_competitors_path(judge.competition)
        elsif class_name == 'Street'
            link_to judge.judge_type.name, competition_street_scores_path(judge.competition)
        elsif class_name == 'Standard'
            link_to judge.judge_type.name, competition_standard_scores_path(judge.competition)
        else
            "please update the scoring_link function (#{judge.competition.event.event_class})"
        end
    end

    def scores_link(event)
        if event.event_class == 'Two Attempt Distance'
            link_to 'View Scores', distance_attempts_event_path(event) 
        elsif event.event_class == 'Freestyle'
            link_to 'View Scores', freestyle_scores_event_path(event)
        elsif event.event_class == 'Flatland'
            link_to 'View Scores', freestyle_scores_event_path(event)
        elsif event.event_class == 'Street'
            #link_to 'View Scores', judge_street_scores_path(judge)
        elsif event.event_class == 'Standard'
            #link_to 'View Scores', judge_standard_scores_path(judge)
        else
            "please update the scores_link function (#{event.event_class})"
        end
    end
end
