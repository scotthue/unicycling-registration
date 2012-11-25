require 'spec_helper'

describe AttendingController do
  before(:each) do
    @reg = FactoryGirl.create(:registrant)
    sign_in FactoryGirl.create(:user)
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new', {:id => @reg}
      response.should be_success
    end

    it "returns a list of all of the events" do
      @category1 = FactoryGirl.create(:category, :position => 1)
      @category3 = FactoryGirl.create(:category, :position => 3)
      @category2 = FactoryGirl.create(:category, :position => 2)

      get 'new', {:id => @reg}
      assigns(:categories).should == [@category1, @category2, @category3]
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @ec1 = FactoryGirl.create(:event_choice)
      @attributes = {
        :registrant_choices_attributes => [
          { :value => "1",
            :event_choice_id => @ec1.id
          }
      ]}
    end
    it "returns http success" do
      post 'create', {:id => @reg, :registrant => @attributes}
      response.should redirect_to (@reg)
    end

    it "creates a corresponding event_choice when checkbox is selected" do
      post 'create', {:id => @reg, :registrant => @attributes}
      RegistrantChoice.count.should == 1
    end

    it "doesn't create a new entry if one already exists" do
      RegistrantChoice.count.should == 0
      post 'create', {:id => @reg, :registrant => @attributes}
      post 'create', {:id => @reg, :registrant => @attributes}
      RegistrantChoice.count.should == 1
    end
  end
end
