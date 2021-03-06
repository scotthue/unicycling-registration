require 'spec_helper'

describe "award_labels/index" do
  before(:each) do
    @user = FactoryGirl.create(:award_admin_user)
    assign(:user, @user)
    assign(:award_labels, [
      FactoryGirl.create(:award_label,
                         bib_number: 123,
                         line_1: "Robin Dunlop & Connie Cotter",
                         line_2: "Pairs Freestyle",
                         line_3: "TCUC",
                         line_4: "Adults",
                         line_5: "Winner",
                         place: 2
                        ),
      FactoryGirl.create(:award_label)])
    @award_label = FactoryGirl.build(:award_label)
  end

  it "renders a list of award_labels" do
    render
    assert_select "tr>td", text: 123.to_s, count: 1
    assert_select "tr>td", text: "Robin Dunlop & Connie Cotter".to_s, count: 1
    assert_select "tr>td", text: "Pairs Freestyle".to_s, count: 1
    assert_select "tr>td", text: "TCUC".to_s, count: 1
    assert_select "tr>td", text: "Adults".to_s, count: 1
    assert_select "tr>td", text: "Winner".to_s, count: 1
    assert_select "tr>td", text: "2nd Place".to_s, count: 1
    assert_select "tr>td", text: 2.to_s, count: 1
  end
  describe "award_labels/new" do
    before(:each) do
      assign(:award_label, FactoryGirl.build(:award_label))
    end

    it "renders new award_label form" do
      render

      assert_select "form", action: user_award_labels_path(@user), method: "post" do
        assert_select "input#award_label_bib_number", name: "award_label[bib_number]"
        assert_select "input#award_label_line_1", name: "award_label[line_1]"
        assert_select "input#award_label_line_2", name: "award_label[line_2]"
        assert_select "input#award_label_line_3", name: "award_label[line_3]"
        assert_select "input#award_label_line_4", name: "award_label[line_4]"
        assert_select "input#award_label_line_5", name: "award_label[line_5]"
        assert_select "input#award_label_place", name: "award_label[place]"
        assert_select "select#award_label_registrant_id", name: "award_label[registrant_id]"
      end
    end
  end
end
