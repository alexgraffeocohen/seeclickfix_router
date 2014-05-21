require 'spec_helper'

describe APIParser do
  it 'can grab an SCF location from address' do
    address = '250 West 82 Street, New York, NY'
    response = APIParser.grab_location(address)

    expect(response).to eq('upper-west-side')
  end

  it 'can find open issues based off of SCF place' do
    place = 'east-rock'
    response = APIParser.find_issues(place, 'open')
    first_issue = response.first

    expect(first_issue.values).should include('open')
  end
end