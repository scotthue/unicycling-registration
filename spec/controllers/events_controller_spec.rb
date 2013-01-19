require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe EventsController do
   before(:each) do
     user = FactoryGirl.create(:super_admin_user)
     sign_in user
     @category = FactoryGirl.create(:category)
   end


  # This should return the minimal set of attributes required to create a valid
  # Event. As you add validations to Event, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
    name: "My Event"
    }
  end

  describe "as a normal user" do
    before(:each) do 
      @user = FactoryGirl.create(:user)
      sign_in @user 
    end   

    it "Cannot read events" do
      get :index, {:category_id => @category.id}
      response.should redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "assigns all events as @events" do
      event = FactoryGirl.create(:event, :category => @category)
      event2 = FactoryGirl.create(:event)
      get :index, {:category_id => @category.id}
      assigns(:events).should eq([event])
      assigns(:event).should be_a_new(Event)
      assigns(:category).should eq(@category)
    end
  end

  describe "GET edit" do
    it "assigns the requested event as @event" do
      event = FactoryGirl.create(:event, :category => @category)
      get :edit, {:id => event.to_param}
      assigns(:event).should eq(event)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Event" do
        expect {
          post :create, {:event => valid_attributes, :category_id => @category.id}
        }.to change(Event, :count).by(1)
      end

      it "assigns a newly created event as @event" do
        post :create, {:event => valid_attributes, :category_id => @category.id}
        assigns(:event).should be_a(Event)
        assigns(:event).should be_persisted
      end

      it "redirects to the created event" do
        post :create, {:event => valid_attributes, :category_id => @category.id}
        response.should redirect_to(category_events_path(@category))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event as @event" do
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        post :create, {:event => {}, :category_id => @category.id}
        assigns(:event).should be_a_new(Event)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        post :create, {:event => {}, :category_id => @category.id}
        response.should render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested event" do
        event = FactoryGirl.create(:event)
        # Assuming there are no other events in the database, this
        # specifies that the Event created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Event.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => event.to_param, :event => {'these' => 'params'}}
      end

      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        put :update, {:id => event.to_param, :event => valid_attributes}
        assigns(:event).should eq(event)
      end

      it "redirects to the event" do
        event = FactoryGirl.create(:event, :category => @category)
        put :update, {:id => event.to_param, :event => valid_attributes}
        response.should redirect_to(category_events_path(@category))
      end
    end

    describe "with invalid params" do
      it "assigns the event as @event" do
        event = FactoryGirl.create(:event)
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        put :update, {:id => event.to_param, :event => {}}
        assigns(:event).should eq(event)
      end

      it "re-renders the 'edit' template" do
        event = FactoryGirl.create(:event)
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        put :update, {:id => event.to_param, :event => {}}
        response.should render_template("edit")
      end
    end
    describe "with nested event_choices" do
      it "accepts nested attributes" do
        event = FactoryGirl.create(:event)
        expect {
          put :update, {:id => event.to_param, :event => { 
          :name => "My Name", 
          :event_choices_attributes => [ 
            { 
          :export_name => "100m", 
          :cell_type => "boolean" 
        }] }}
        }.to change(EventChoice, :count).by(1)
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event" do
      event = FactoryGirl.create(:event)
      expect {
        delete :destroy, {:id => event.to_param}
      }.to change(Event, :count).by(-1)
    end

    it "redirects to the events list" do
      event = FactoryGirl.create(:event, :category => @category)
      delete :destroy, {:id => event.to_param}
      response.should redirect_to(category_events_path(@category))
    end
  end

end
