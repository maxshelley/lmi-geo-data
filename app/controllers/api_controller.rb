class ApiController < ApplicationController
  def distances_by_name
    if results_params[:location_from] && results_params[:location_to]
      @location_from = results_params[:location_from]
      @location_to = results_params[:location_to]
      @location_from_origin = Job.geocode("#{@location_from}, UK") rescue nil
      @location_to_origin = Job.geocode("#{@location_to}, UK") rescue nil
      if @location_from_origin && @location_to_origin
        @response = HTTParty.get("http://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=#{@location_from_origin.lat},#{@location_from_origin.lng}&destinations=#{@location_to_origin.lat},#{@location_to_origin.lng}")
        @distance = @response["rows"][0]["elements"][0]["distance"]["text"]
      end
    end
  end

  def latlng_params
    results_params[:to_lat] && results_params[:to_lng] && results_params[:from_lat] && results_params[:from_lng]
  end

  def distances_by_latlng
    if latlng_params
      @response = HTTParty.get("http://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=#{results_params[:to_lat]},#{results_params[:from_lng]}&destinations=#{results_params[:to_lat]},#{results_params[:to_lng]}")
      @distance = @response["rows"][0]["elements"][0]["distance"]["text"]
    end
  end

  def crime_url(crime_params)
    "http://data.police.uk/api/crimes-street/all-crime?lat=#{crime_params[:lat].to_i}&lng=#{crime_params[:lng].to_i}&date=2014-01"
  end

  def group_crime response
    hash = {}
    grouped = response.group_by { |thing| thing["category"] }
    grouped.each { |group| hash[group[0]] = group[1].count }
    hash
  end

  def crime_latlng
    if crime_params
      @url = crime_url(crime_params)
      @response = HTTParty.get(@url)
      @types = group_crime(@response)
    end
  end

  def results
    #this method returns a grouped collection of jobs to the collection
    if results_params[:location_from] && results_params[:location_to]
      
      @location_from = results_params[:location_from]
      @location_to = results_params[:location_to]

      @location_from_origin = Job.geocode("#{@location_from}, UK") rescue nil
      @location_to_origin = Job.geocode("#{@location_to}, UK") rescue nil

      if @location_from_origin && @location_to_origin
        @response = HTTParty.get("http://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=#{@location_from_origin.lat},#{@location_from_origin.lng}&destinations=#{@location_to_origin.lat},#{@location_to_origin.lng}")
        @distance = @response["rows"][0]["elements"][0]["distance"]["text"]
      end

    end

    @keyword = results_params[:keyword]
    @results = Job.grouped_by_lat_lng(@keyword)
  end

  def map
    @keyword = results_params[:keyword]
    @results = Job.grouped_by_lat_lng(@keyword)
  end

  private
  
  def results_params
    params.permit(:keyword, :location_from, :location_to, :from_lat, :from_lng, :to_lat, :to_lng)
  end

  def crime_params
    params.permit(:lat, :lng)
  end

end