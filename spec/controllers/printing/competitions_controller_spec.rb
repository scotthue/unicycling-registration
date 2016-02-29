require 'spec_helper'

describe Printing::CompetitionsController do
  before do
    FactoryGirl.create(:event_configuration)
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
  end
  let(:competition) { FactoryGirl.create(:competition) }

  describe "GET announcer" do
    it "renders" do
      get :announcer, id: competition.id
      expect(response).to be_success
    end
  end

  describe "GET start_list" do
    it "renders" do
      get :start_list, id: competition.id
      expect(response).to be_success
    end
  end

  describe "GET heat_recording" do
    it "renders" do
      get :heat_recording, id: competition.id
      expect(response).to be_success
    end
  end

  describe "GET single_attempt_recording" do
    it "renders" do
      get :single_attempt_recording, id: competition.id
      expect(response).to be_success
    end
  end

  describe "GET two_attempt_recording" do
    it "renders" do
      get :two_attempt_recording, id: competition.id
      expect(response).to be_success
    end
  end

  describe "GET results" do
    it "renders" do
      get :results, id: competition.id
      expect(response).to be_success
    end
  end
end