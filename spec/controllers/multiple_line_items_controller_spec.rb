require 'rails_helper'

RSpec.describe MultipleLineItemsController do
  before :each do
    sign_in
    @protocol = create(:protocol)
    @service = create(:service)
  end

  describe "GET #new" do

    it "renders a template to add a service to mutliple arms" do
      xhr :get, :new, {
        protocol_id: @protocol.id,
        service_id: @service.id,
        format: :js
      }
      expect(assigns(:protocol)).to eq(@protocol)
      expect(assigns(:selected_service)).to eq(@service.id.to_s)
      expect(assigns(:services)).to eq(Service.all)
    end
  end

  describe "GET #edit" do
    it "renders a template to remove a service from mutliple arms" do
      xhr :get, :new, {
        protocol_id: @protocol.id,
        service_id: @service.id,
        format: :js
      }
      expect(assigns(:protocol)).to eq(@protocol)
      expect(assigns(:selected_service)).to eq(@service.id.to_s)
      expect(assigns(:services)).to eq(Service.all)
    end
  end

  describe "PUT #update" do

    it "should create multiple line items" do
      arm1 = create(:arm)
      arm2 = create(:arm)
      put :update, {
        header_text: "Add",
        arm_ids: [arm1.id.to_s, arm2.id.to_s],
        service_id: @service.id,
        format: :js
      }
      arm1.reload
      arm2.reload
      expect(arm1.line_items.count).to eq(1)
      expect(arm1.line_items.first.service_id).to eq(@service.id)
      expect(arm2.line_items.count).to eq(1)
      expect(arm2.line_items.first.service_id).to eq(@service.id)
    end

    it "should remove multiple line items" do
      arm1 = create(:arm)
      arm2 = create(:arm)
      line_item1 = create(:line_item, arm_id: arm1.id, service_id: @service.id)
      line_item2 = create(:line_item, arm_id: arm2.id, service_id: @service.id)
      arm1.reload
      arm2.reload
      put :update, {
        header_text: "Remove",
        arm_ids: [arm1.id.to_s, arm2.id.to_s],
        service_id: @service.id,
        format: :js
      }
      arm1.reload
      arm2.reload
      expect(arm1.line_items.count).to eq(0)
      expect(arm2.line_items.count).to eq(0)
    end

  end

end