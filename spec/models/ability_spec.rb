require "cancan/matchers"
require "spec_helper"

describe "Ability" do
  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      ENV["ONSITE_REGISTRATION"] = nil
    end
    subject { @ability = Ability.new(@user) }

    it { should be_able_to(:read, @user) }
    it { should_not be_able_to(:read, User.new) }
    it { should be_able_to(:create, StandardSkillRoutine) }


    describe "with Additional Registrant Accesses" do
      before(:each) do
        @ara = FactoryGirl.create(:additional_registrant_access, :user => @user, :accepted_readonly => true)
        @ara_to_me = FactoryGirl.create(:additional_registrant_access, :registrant => FactoryGirl.create(:registrant, :user => @user))
        @ara_to_other = FactoryGirl.create(:additional_registrant_access)
      end
      it { should be_able_to(:read, @ara) }
      it { should be_able_to(:create, @ara) }
      it { should be_able_to(:new, @ara) }
      it { should be_able_to(:invitations, AdditionalRegistrantAccess) }
      it { should be_able_to(:read, @ara.registrant) }
      it { should_not be_able_to(:read_contact_info, @ara.registrant) }

      it { should be_able_to(:decline, @ara_to_me) }
      it { should be_able_to(:accept_readonly, @ara_to_me) }

      it { should_not be_able_to(:read, FactoryGirl.create(:additional_registrant_access)) }
      it { should_not be_able_to(:decline, @ara_to_other) }
      it { should_not be_able_to(:accept_readonly, @ara_to_other) }
    end

    describe "with a registration" do
      let (:registration) { FactoryGirl.create(:registrant, :user => @user) }

      it { should be_able_to(:read, registration) }
      it { should be_able_to(:read_contact_info, registration) }
      it { should be_able_to(:all, registration) }
      it { should be_able_to(:waiver, registration) }
      it { should be_able_to(:empty_waiver, Registrant) }
      describe "with a StandardSkillRoutine" do
        before(:each) do
          @routine = FactoryGirl.create(:standard_skill_routine, :registrant => registration)
        end

        it { should be_able_to(:destroy, @routine) }
      end
    end

    describe "With a payment" do
      let (:payment) { FactoryGirl.create(:payment, :user => @user) }

      it { should be_able_to(:read, payment) }
    end

    describe "when registration is closed" do
      before(:each) do
        FactoryGirl.create(:registration_period, :onsite => false, :end_date => 10.days.ago)
      end

      it { should_not be_able_to(:create, Registrant) }

      describe "when the ONSITE flag is set" do
        before(:each) do
          ENV['ONSITE_REGISTRATION'] = "true"
        end

        it { should be_able_to(:create, Registrant) }
      end
    end
    describe "when standard_skill is closed" do
      before(:each) do
        FactoryGirl.create(:event_configuration, :standard_skill_closed_date => 10.days.ago)
      end

      it { should_not be_able_to(:manage, StandardSkillRoutine) }
      it { should_not be_able_to(:manage, StandardSkillRoutineEntry) }
    end
  end

  describe "as an admin" do
    before(:each) do
      @user = FactoryGirl.create(:admin_user)
    end
    subject { @ability = Ability.new(@user) }

    it { should be_able_to(:read, Registrant) }
    it { should be_able_to(:manage, Competitor) }

    describe "with another user having a registrant" do
      let (:registration) { FactoryGirl.create(:registrant) }
      it { should be_able_to(:read, registration) }
      it { should be_able_to(:manage, registration) }
    end
    describe "when registration is closed" do
      before(:each) do
        FactoryGirl.create(:registration_period, :onsite => false, :end_date => 10.days.ago)
      end

      it { should be_able_to(:create, Registrant) }
      it { should be_able_to(:manage, StandardSkillRoutine) }
      it { should be_able_to(:manage, StandardSkillRoutineEntry) }
    end
    describe "With a payment for another user" do
      let (:payment) { FactoryGirl.create(:payment) }

      it { should be_able_to(:read, payment) }
    end
  end

  describe "as a super_admin" do
    before(:each) do
      @user = FactoryGirl.create(:super_admin_user)
    end
    subject { @ability = Ability.new(@user) }

    it { should be_able_to(:access, :rails_admin) }
  end

  describe "as a judge" do
    before(:each) do
      @user = FactoryGirl.create(:judge_user)
    end
    subject { @ability = Ability.new(@user) }

    it { should be_able_to(:create, Score) }
    it { should be_able_to(:read, StreetScore) }

    describe "with a Competition" do
      before(:each) do
        @ec = FactoryGirl.create(:competition)
      end
      it { should be_able_to(:create_scores, @ec) }
      it { should be_able_to(:read, Competitor) }

      describe "when the Competition is locked" do
        before(:each) do
          @ec.locked = true
          @ec.save!
        end

        it { should_not be_able_to(:create_scores, @ec) }
      end
      describe "with a score" do
        before(:each) do
          @judge = FactoryGirl.create(:judge, :user => @user)
          @score = FactoryGirl.create(:score, :judge => @judge)
          @other_score = FactoryGirl.create(:score) # different user
        end

        it { should be_able_to(:update, @score) }
        it { should_not be_able_to(:update, @other_score) }
      end
    end
  end

  describe "as a chief_judge" do
    before(:each) do
      @ec = FactoryGirl.create(:competition)
      @user = FactoryGirl.create(:user)
      @user.add_role :chief_judge, @ec
      @user.add_role :judge
    end
    subject { @ability = Ability.new(@user) }

    it { should be_able_to(:distance_attempts, @ec) }
    it { should be_able_to(:freestyle_scores, @ec) }
    it { should be_able_to(:administer, @ec) }
    it { should be_able_to(:manage, DistanceAttempt) }
  end

end
