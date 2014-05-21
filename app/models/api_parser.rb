class APIParser
  def self.find_issues(place, status, months_since=1)
    days_after = self.convert_to_days(months_since)
    days_before = days_after - 30
    request = Typhoeus::Request.new(
    "http://seeclickfix.com/api/v2/issues",
    params: {
      place_url: "#{place}",
      before: "#{(Date.today - days_before).to_s}",
      after: "#{(Date.today - days_after).to_s}",
      status: "#{status}",
      per_page: "1000"
    })
    self.hash_from(request, "issues")
  end

  def self.grab_location(address)
    request = Typhoeus::Request.new(
      "http://seeclickfix.com/api/v2/places",
      params: {
        address: address
      })
    response = self.hash_from(request, "places")
    response.first["url_name"]
  end

  def self.map_categories(issues)
    categories = {}.tap do |categories|
      issues.each do |issue|
        summary = issue["summary"]
        categories[summary] ||= 0
        categories[summary] += 1
      end
    end
    self.reduce_categories(categories)
  end

  def self.generate_dash_hash(categories)
    [].tap do |array|
      categories.each do |category, counter|
        array << { label: category, value: counter }
      end
    end
  end

  def self.generate_graph_data(place)
    time_frames = ["1","2","3","4"].reverse
    [].tap do |data|
      time_frames.each do |time_frame|
        month_value = Date.today.month - time_frame.to_i
        data << { x: month_value, y: find_issues(place, "open", time_frame).count }
      end
    end
  end

  def self.reduce_categories(hash)
    sorted = hash.sort_by { |k,v| v }.last(6).reverse
    {}.tap do |data|
      sorted.each do |sorted|
        data[sorted[0]] = sorted[1]
      end
    end
  end

  def self.convert_to_days(month)
    month.to_i * 30
  end

  def self.hash_from(request, api_type)
    JSON.parse(request.run.body)["#{api_type}"]
  end

end