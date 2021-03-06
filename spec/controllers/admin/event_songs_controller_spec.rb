require 'spec_helper'

describe Admin::EventSongsController do
  before(:each) do
    FactoryGirl.create(:event_configuration, music_submission_end_date: Date.today + 4.days)
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET index" do
    it "loads all songs" do
      get :index
      expect(response).to redirect_to(root_url)
    end
    describe "as an admin" do
      before :each do
        sign_out @user
        sign_in FactoryGirl.create(:super_admin_user)
      end
      it "views the songs list index" do
        get :index
        expect(response).to_not redirect_to(root_url)
      end
    end
  end
end
