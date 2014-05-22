require 'spec_helper'

describe APIParser do
  let(:address) { "250 West 82 Street, New York, NY" }

  it 'can grab an SCF location from address' do
    response = APIParser.grab_location(address)

    expect(response).to eq('upper-west-side')
  end

  it 'can find open issues based off of SCF place' do
    place = 'east-rock'
    response = APIParser.find_issues(place, 'open')
    first_issue = response.first
    address = first_issue["address"]

    expect(first_issue.values).to include('Open')
    expect(address).to include('New Haven')
  end
end