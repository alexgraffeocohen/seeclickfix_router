require 'spec_helper'

describe SearchesController do
  describe "GET #show" do
    it 'should redirect to dashboard' do
      get :show, address: 'Yale University', city: 'New Haven', state: 'CT'
      expect(response).to be_a_redirect
    end
  end
end
