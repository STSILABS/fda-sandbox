require 'spec_helper'

RSpec.describe HomeController do

  it "should get home with 200 (success)" do 
    get :index
    expect(response.status).to eq(200)
  end

end
