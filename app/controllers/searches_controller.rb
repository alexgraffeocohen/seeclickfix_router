class SearchesController < ApplicationController

  def search
  end

  def show
    full_address = "#{params[:address]}, #{params[:city]}, #{params[:state]}"
    scf_location = APIParser.grab_location(full_address)

    if fields_missing?
      flash.now[:notice] = "Please fill in all fields"
      return render 'search' 
    elsif no_recent_issues_for(scf_location)
      flash.now[:notice] = "Sorry, there were no recent issues reported in this location."
      return render 'search'
    else
      update_dash_with(scf_location, full_address)
      redirect_to 'http://see-click-fix-dash.herokuapp.com/seeclickfix'
    end
  end

  private

  def fields_missing?
    params[:address].blank? || params[:city].blank? || params[:state].blank?
  end

  def no_recent_issues_for(address)
    open_issues = APIParser.find_issues(address, 'open')
    open_issues.blank?
  end

  def update_dash_with(address, full_address)
    open_issues = APIParser.find_issues(address, 'open')
    closed_issues = APIParser.find_issues(address, 'closed')
    acknowledged_issues = APIParser.find_issues(address, 'acknowledged')
    all_issues = open_issues + closed_issues + acknowledged_issues

    send_requests_for([open_issues, closed_issues, acknowledged_issues])
    update_dash('welcome', auth_token: 'seeclickfix', text: "#{full_address}")
    fetch_categories_for(all_issues)
    generate_graph_for(address)
  end

  def fetch_categories_for(all_issues)
    category_hash = APIParser.map_categories(all_issues)
    update_dash('categories', auth_token: 'seeclickfix', items: APIParser.generate_dash_hash(category_hash))
  end

  def generate_graph_for(address)
    data = APIParser.generate_graph_data(address)
    total_closed = 0
    data.each do |datum|
      total_closed += datum[:y]
    end
    update_dash('graph', auth_token: 'seeclickfix', points: data, displayedValue: total_closed / data.count)
  end

  def send_requests_for(data)
    dash_url = "http://see-click-fix-dash.herokuapp.com/widgets"
    data.each do |datum|
      status = datum.first["status"].downcase
      update_dash(status, auth_token: 'seeclickfix', current: datum.count)
    end
  end

  def update_dash(widget_name, request_hash)
    dash_url = "http://see-click-fix-dash.herokuapp.com/widgets"
    Typhoeus.post("#{dash_url}/#{widget_name}", body: request_hash.to_json)
  end

end
