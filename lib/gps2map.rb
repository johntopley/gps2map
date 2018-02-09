# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'ostruct'
require 'thor'
require 'erb'
require 'csv'

require_relative 'core_ext/integer'
require_relative 'gps2map/version'

# Namespace all the gem code.
module GPS2Map
  DIGITS          = 6
  LATITUDE_OFFSET = 0.005000
  MARKERS         = 15

  Coordinate = Struct.new(:latitude, :longitude)
  Marker     = Struct.new(:latitude, :longitude, :label)

  # Class that takes an input file containing GPS co-ordinates and outputs an HTML file containing a
  # Google Map of those co-ordinates.
  class GPS2Map < Thor
    desc 'generate <input.gpx|.kml|.tcx> <output.html>', 'Generates a Google Map from an input file'
    option :markers, type: :numeric, default: MARKERS, desc: 'The number of markers to plot on the map'
    def generate(input_file, output_file)
      vars           = {}
      vars[:api_key] = ENV['GOOGLE_MAPS_API_KEY'] || abort('No GOOGLE_MAPS_API_KEY provided.')
      vars[:title]   = input_file
      coordinates    = []
      markers        = []
      label          = 0
      latitudes, longitudes = parse_file(input_file)
      interval = latitudes.length / options[:markers]

      latitudes.each_with_index do |latitude, i|
        longitude = longitudes[i]
        coordinates << Coordinate.new(latitude, longitude)
        markers << Marker.new(latitude, longitude, label += 1) if i > 1 && (i % interval).zero?
      end

      vars[:coordinates]     = coordinates
      vars[:markers]         = markers
      vars[:map_centre_lat]  = mean_of(coordinates.map(&:latitude)) + LATITUDE_OFFSET
      vars[:map_centre_long] = mean_of(coordinates.map(&:longitude))
      vars[:map_start_lat]   = coordinates.first.latitude
      vars[:map_start_long]  = coordinates.first.longitude
      write_output_file(output_file, execute_template(vars))
      puts "Plotted #{latitudes.length.to_comma_formatted} co-ordinates with #{markers.length} markers."
    end

    private

    def execute_template(variables)
      template = File.join(__dir__, 'map.erb')
      context = OpenStruct.new(variables).instance_eval { binding }
      # Set the ERB trim mode to suppress newlines.
      ERB.new(File.read(template), 0, '>').result(context)
    end

    def mean_of(coordinates)
      coordinates.sum.fdiv(coordinates.length).round(DIGITS)
    end

    def parse_file(input_file)
      case File.extname(input_file).downcase
      when '.gpx'
        parse_gpx(input_file)
      when '.kml'
        parse_kml(input_file)
      when '.tcx'
        parse_tcx(input_file)
      end
    end

    def parse(input_file, selector)
      File.open(input_file, 'r') do |fi|
        doc = Nokogiri::XML(fi)
        doc.css(selector).each { |el| yield(el) }
      end
    end

    def parse_gpx(input_file)
      latitudes  = []
      longitudes = []
      parse(input_file, 'trkpt') do |el|
        latitudes  << el['lat'].to_f.round(DIGITS)
        longitudes << el['lon'].to_f.round(DIGITS)
      end
      [latitudes, longitudes]
    end

    def parse_kml(input_file)
      latitudes  = []
      longitudes = []
      parse(input_file, 'Point coordinates') do |el|
        # KML has longitude first.
        longitudes << CSV.parse(el.text.strip).first.first.to_f.round(DIGITS)
        latitudes  << CSV.parse(el.text.strip).first[1].to_f.round(DIGITS)
      end
      [latitudes, longitudes]
    end

    def parse_tcx(input_file)
      latitudes  = []
      longitudes = []
      File.open(input_file, 'r') do |fi|
        doc = Nokogiri::XML(fi)
        doc.css('LatitudeDegrees').each { |el| latitudes << el.text.to_f.round(DIGITS) }
        doc.css('LongitudeDegrees').each { |el| longitudes << el.text.to_f.round(DIGITS) }
      end
      [latitudes, longitudes]
    end

    def write_output_file(output_file, data)
      File.open(output_file, 'w') { |fi| fi.write(data) }
    end
  end
end
