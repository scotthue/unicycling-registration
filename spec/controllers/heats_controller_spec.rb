# == Schema Information
#
# Table name: lane_assignments
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  heat           :integer
#  lane           :integer
#  created_at     :datetime
#  updated_at     :datetime
#  competitor_id  :integer
#
# Indexes
#
#  index_lane_assignments_on_competition_id                    (competition_id)
#  index_lane_assignments_on_competition_id_and_heat_and_lane  (competition_id,heat,lane) UNIQUE
#

require 'spec_helper'

describe HeatsController do
  before(:each) do
    @competition = FactoryGirl.create(:timed_competition, uses_lane_assignments: true)
    director = FactoryGirl.create(:user)
    director.add_role(:director, @competition.event)
    sign_in director
    @reg = FactoryGirl.create(:registrant)
    @competitor = FactoryGirl.create(:event_competitor, competition: @competition)
    @competitor.members.first.update_attribute(:registrant_id, @reg.id)
  end

  describe "GET index" do
    before do
      allow_any_instance_of(Competitor).to receive(:best_time).and_return("2:20")
      get :index, competition_id: @competition.id
    end
    it "assigns all competitors as @competitors" do
      expect(assigns(:competitors)).to eq([@competitor])
    end

    it "displays the best time for each competitor" do
      expect(response.body).to match(/2:20/)
    end
  end

  describe "GET new" do
    it "assigns the requested lane_assignment as @lane_assignment" do
      get :new, competition_id: @competition.id
      expect(response).to be_success
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "calls the heat assignment creatorcreates" do
        allow_any_instance_of(HeatAssignmentCreator).to receive(:perform).and_return(true)
        post :create, lanes: 1, competition_id: @competition.id

        expect(flash[:notice]).to match(/Created Heats/)
      end
    end

    describe "with invalid params" do
      describe "when the lane_number is invalid" do
        def do_action
          post :create, competition_id: @competition.id, lanes: 0
        end

        it "returns an error" do
          do_action
          expect(flash[:alert]).to match(/Invalid number of lanes/)
        end
        it "doesn't change the number of lane assignments" do
          expect do
            do_action
          end.not_to change(LaneAssignment, :count)
        end
      end

      describe "when there are existing lane assignments" do
        before { allow_any_instance_of(Competition).to receive(:lane_assignments).and_return(["thing"]) }

        it "returns an error" do
          post :create, competition_id: @competition.id, lanes: 5
          expect(flash[:alert]).to match(/Cannot auto-assign with existing Lane Assignments/)
        end
      end
    end
  end

  describe "#destroy_all" do
    before { FactoryGirl.create(:lane_assignment, competitor: @competitor, competition: @competition) }
    it "removes all lane assignments" do
      expect do
        delete :destroy_all, competition_id: @competition.id
      end.to change(LaneAssignment, :count).by(-1)
    end
  end
end