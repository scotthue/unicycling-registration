require 'spec_helper'

xdescribe Registrants::BuildController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # Registrant. As you add validations to Registrant, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      first_name: "Robin",
      last_name: "Dunlop",
      gender: "Male",
      user_id: @user.id,
      birthday: Date.new(1982, 01, 19),
      contact_detail_attributes: {
        address: "123 Fake Street",
        city: "Madison",
        state_code: "WI",
        country_residence: "US",
        zip: "12345",
        club: "TCUC",
        club_contact: "Connie",
        usa_member_number: "12345",
        volunteer: false,
        emergency_name: "Caitlin",
        emergency_relationship: "Sig. Oth.",
        emergency_attending: true,
        emergency_primary_phone: "306-222-1212",
        emergency_other_phone: "911",
        responsible_adult_name: "Andy",
        responsible_adult_phone: "312-555-5555"
      }
    }
  end

  describe "GET new" do
    it "assigns a new competitor as @registrant" do
      get :new, {registrant_type: 'competitor'}
      assigns(:registrant).should be_a_new(Registrant)
      assigns(:registrant).competitor.should == true
    end
    it "returns a list of all of the events" do
      @category1 = FactoryGirl.create(:category, :position => 1)
      @category3 = FactoryGirl.create(:category, :position => 3)
      @category2 = FactoryGirl.create(:category, :position => 2)

      get 'new', {registrant_type: 'competitor'}
      assigns(:categories).should == [@category1, @category2, @category3]
    end

    describe "when the system is 'closed'" do
      before(:each) do
        FactoryGirl.create(:registration_period, :start_date => Date.new(2010, 01, 01), :end_date => Date.new(2010, 02, 02))
      end
      it "should not succeed" do
        EventConfiguration.closed?.should == true
        get :new
        response.should_not be_success
      end
    end
  end

  describe "GET edit" do
    it "assigns the requested registrant as @registrant" do
      registrant = FactoryGirl.create(:competitor, :user => @user)
      get :edit, {:id => registrant.to_param}
      assigns(:registrant).should eq(registrant)
    end
    it "should not load categories for a noncompetitor" do
      category1 = FactoryGirl.create(:category, :position => 1)
      registrant = FactoryGirl.create(:noncompetitor, :user => @user)
      get :edit, {:id => registrant.to_param}
      response.should be_success
      assigns(:categories).should be_nil
    end
  end

  describe "POST create" do
    describe "with valid params" do
      before(:each) do
        @ws20 = FactoryGirl.create(:wheel_size_20)
        @ws24 = FactoryGirl.create(:wheel_size_24)
        @comp_attributes = valid_attributes.merge({registrant_type: 'competitor'})
      end
      it "creates a new Registrant" do
        expect {
          post :create, {:registrant => @comp_attributes}
        }.to change(Registrant, :count).by(1)
      end

      it "assigns the registrant to the current user" do
        expect {
          post :create, {:registrant => valid_attributes.merge(
            registrant_type: 'competitor')
          }
        }.to change(Registrant, :count).by(1)
        Registrant.last.user.should == @user
        Registrant.last.contact_detail.should_not be_nil
      end

      it "sets the registrant as a competitor" do
        post :create, {:registrant => @comp_attributes}
        Registrant.last.competitor.should == true
      end

      it "assigns a newly created registrant as @registrant" do
        post :create, {:registrant => @comp_attributes}
        assigns(:registrant).should be_a(Registrant)
        assigns(:registrant).should be_persisted
      end

      it "redirects to the created registrant" do
        post :create, {:registrant => @comp_attributes}
        response.should redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved registrant as @registrant" do
        # Trigger the behavior that occurs when invalid params are submitted
        Registrant.any_instance.stub(:save).and_return(false)
        post :create, {:registrant => {registrant_type: 'competitor'}}
        assigns(:registrant).should be_a_new(Registrant)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Registrant.any_instance.stub(:save).and_return(false)
        post :create, {:registrant => {registrant_type: 'competitor'}}
        response.should render_template("new")
      end
      it "has categories" do
        # Trigger the behavior that occurs when invalid params are submitted
        category1 = FactoryGirl.create(:category, :position => 1)
        Registrant.any_instance.stub(:save).and_return(false)
        post :create, {:registrant => {registrant_type: 'competitor'}}
        assigns(:categories).should == [category1]
      end
      it "should not load categories for a noncompetitor" do
        category1 = FactoryGirl.create(:category, :position => 1)
        Registrant.any_instance.stub(:save).and_return(false)
        post :create, {:registrant => {registrant_type: 'noncompetitor'}}
        assigns(:categories).should be_nil
      end
    end
    describe "When creating nested registrant choices" do
      before(:each) do
        @reg = FactoryGirl.create(:registrant, :user => @user)
        @ev = FactoryGirl.create(:event)
        @ec = FactoryGirl.create(:event_choice, :event => @ev)
        @attributes = valid_attributes.merge({
                                               registrant_type: 'competitor',
                                               :registrant_event_sign_ups_attributes => [
                                                 { :signed_up => "1",
                                                   :event_category_id => @ev.event_categories.first.id,
                                                   :event_id => @ev.id
                                                 }
                                               ],
                                               :registrant_choices_attributes => [
                                                 { :event_choice_id => @ec.id,
                                                   :value => "1"
                                                 }
                                               ]
                                             })
      end

      it "creates a corresponding event_choice when checkbox is selected" do
        expect {
          post 'create', {:id => @reg, :registrant => @attributes}
        }.to change(RegistrantChoice, :count).by(1)
      end

      it "doesn't create a new entry if one already exists" do
        RegistrantChoice.count.should == 0
        put :update, {:id => @reg.to_param, :registrant => @attributes}
        RegistrantChoice.count.should == 1
      end
      it "can update an existing registrant_choice" do
        put :update, {:id => @reg.to_param, :registrant => @attributes}
        @attributes[:registrant_event_sign_ups_attributes][0][:id] = RegistrantEventSignUp.first.id
        @attributes[:registrant_choices_attributes][0][:id] = RegistrantChoice.first.id
        put :update, {:id => @reg.to_param, :registrant => @attributes}
        response.should redirect_to(registrant_registrant_expense_items_path(@reg))
      end
    end

    describe "when creating registrant_event_sign_ups" do
      before(:each) do
        @reg = FactoryGirl.create(:registrant, :user => @user)
        @ecat = FactoryGirl.create(:event).event_categories.first
        @attributes = valid_attributes.merge({
                                               registrant_type: 'competitor',
                                               :registrant_event_sign_ups_attributes => [
                                                 { :event_category_id => @ecat.id,
                                                   :event_id => @ecat.event.id,
                                                   :signed_up => "1"
                                             }
                                               ]
                                             })
        @new_attributes = valid_attributes.merge({
                                                   registrant_type: 'competitor',
                                                   :registrant_event_sign_ups_attributes => [
                                                     { :event_category_id => @ecat.id,
                                                       :event_id => @ecat.event.id,
                                                       :signed_up => "0"
                                                 }
                                                   ]
                                                 })
      end

      it "creates corresponding registrant_event_sign_ups" do
        expect {
          post 'create', {:id => @reg, :registrant => @attributes}
        }.to change(RegistrantEventSignUp, :count).by(1)
      end

      it "can update the registrant_event_sign_up" do
        put :update, {:id => @reg.to_param, :registrant => @attributes}
        response.should redirect_to(registrant_registrant_expense_items_path(@reg))
        @new_attributes[:registrant_event_sign_ups_attributes][0][:id] = RegistrantEventSignUp.first.id
        expect {
          put :update, {:id => @reg.to_param, :registrant => @new_attributes}
        }.to change(RegistrantEventSignUp, :count).by(0)
        response.should redirect_to(registrant_registrant_expense_items_path(@reg))
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested registrant" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        # Assuming there are no other registrants in the database, this
        # specifies that the Registrant created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Registrant.any_instance.should_receive(:update_attributes).with({})
        put :update, {:id => registrant.to_param, :registrant => {'these' => 'params'}}
      end

      it "assigns the requested registrant as @registrant" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        put :update, {:id => registrant.to_param, :registrant => valid_attributes}
        assigns(:registrant).should eq(registrant)
      end

      it "cannot change the competitor to a non-competitor" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        put :update, {:id => registrant.to_param, :registrant => valid_attributes.merge({registrant_type: 'noncompetitor'})}
        assigns(:registrant).should eq(registrant)
        assigns(:registrant).competitor.should == true
      end

      it "redirects competitors to the items" do
        registrant = FactoryGirl.create(:competitor, :user => @user)
        put :update, {:id => registrant.to_param, :registrant => valid_attributes}
        response.should redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
      it "redirects noncompetitors to the items" do
        registrant = FactoryGirl.create(:noncompetitor, :user => @user)
        put :update, {:id => registrant.to_param, :registrant => valid_attributes}
        response.should redirect_to(registrant_registrant_expense_items_path(Registrant.last))
      end
    end

    describe "with invalid params" do
      let(:registrant) { FactoryGirl.create(:competitor, user: @user) }
      let(:do_action) {
        put :update, {:id => registrant.to_param, :registrant => {registrant_type: 'competitor'}}
      }
      it "assigns the registrant as @registrant" do
        # Trigger the behavior that occurs when invalid params are submitted
        Registrant.any_instance.stub(:save).and_return(false)
        do_action
        assigns(:registrant).should eq(registrant)
      end
      it "loads the categories" do
        category1 = FactoryGirl.create(:category, :position => 1)
        Registrant.any_instance.stub(:save).and_return(false)
        do_action
        assigns(:categories).should == [category1]
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Registrant.any_instance.stub(:save).and_return(false)
        do_action
        response.should render_template("edit")
      end
    end
  end
end
