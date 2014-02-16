require 'spec_helper'

describe AwardLabel do
  before(:each) do
    @al = FactoryGirl.create(:award_label)
  end

  it "has a valid factory" do
    @al.valid?.should == true
  end

  it "must have a registrant" do
    @al.registrant_id = nil
    @al.valid?.should == false
  end

  it "must have a user" do
    @al.user_id = nil
    @al.valid?.should == false
  end

  it "must have a place" do
    @al.place = nil
    @al.valid?.should == false
  end

  it "must have a positive place" do
    @al.place = 0
    @al.valid?.should == false
  end


  describe "with a solo competitor" do
    before(:each) do
      @comp = FactoryGirl.create(:event_competitor)
      @reg = @comp.registrants.first
      Delorean.jump 2
      @comp.touch # to update the gender (by causing it to notice that a registrant member exists
      @comp.place = 1
      @al = AwardLabel.new
      @al.user = FactoryGirl.create(:user)
      @al.populate_from_competitor(@comp, @reg)
    end
    it "Can create the awards label from a competitor" do
      @al.line_1.should == "#{@reg.first_name} #{@reg.last_name}"
      @al.valid?.should == true
    end

    it "displays both names if in a pair" do
      @reg2 = FactoryGirl.create(:competitor, :first_name => "Bob", :last_name => "Smith")
      FactoryGirl.create(:member, :competitor => @comp, :registrant => @reg2)
      @comp.reload

      @al.populate_from_competitor(@comp, @reg)
      @al.line_1.should == "#{@reg.first_name} #{@reg.last_name} & #{@reg2.first_name} #{@reg2.last_name}"
    end

    it "displays the event name as line 2 for freestyle events" do
      competition = @comp.competition
      competition.scoring_class = "Freestyle"
      competition.name = "Hello"
      ev = competition.event
      ev.name = "Individual"
      ev.save!
      competition.save!

      @al.populate_from_competitor(@comp, @reg)
      @al.line_2.should == "Individual"
    end

    it "displays the competition name as line 2 for distance events" do
      competition = @comp.competition
      competition.scoring_class = "Distance"
      competition.name = "10k Standard"
      ev = competition.event
      ev.name = "10k"
      ev.save!
      competition.save!

      @al.populate_from_competitor(@comp, @reg)
      @al.line_2.should == "10k Standard"
    end

    it "displays the team name as line 3" do
      @comp.custom_name = "Robin Team"
      @al.populate_from_competitor(@comp, @reg)
      @al.line_3.should == "Robin Team"
    end

    describe "when the competitor has expert results" do
      before(:each) do
        @comp.competition.scoring_class = "Distance"
        @comp.competition.has_age_groups = true
        @comp.competition.save!
        @comp.overall_place = 3
      end

      it "uses the age group and the gender as line 4" do
        @al.populate_from_competitor(@comp, @reg, false)
        @al.line_4.should == "No Age Group for 99-Male"
      end

      it "sets the age group to Expert Male when expert" do
        @al.populate_from_competitor(@comp, @reg, true)
        @al.line_4.should == "Expert Male"
      end
    end

    it "stores the competitor.result as details, and line 5" do
      @comp.competition.scoring_class = "Ranked"
      @comp.competition.save!
      FactoryGirl.create(:external_result, :competitor => @comp, :rank => 2, :details => "Some")

      @comp.reload
      @al.populate_from_competitor(@comp, @reg)
      @al.line_5.should == "Some"
    end

    it "sets the award place from the competitor" do
      @comp.place = 2
      @al.populate_from_competitor(@comp, @reg)
      @al.place.should == 2
    end

    it "translates from places to line6" do
      @al.place = 1
      @al.line_6.should == "1st Place"
      @al.place = 2
      @al.line_6.should == "2nd Place"
      @al.place = 3
      @al.line_6.should == "3rd Place"
      @al.place = 4
      @al.line_6.should == "4th Place"
      @al.place = 5
      @al.line_6.should == "5th Place"
      @al.place = 6
      @al.line_6.should == "6th Place"
    end
  end
end
