# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.map_styles = [
    {
        "featureType": "landscape",
        "stylers": [
            {
                "saturation": -100
            },
            {
                "lightness": 65
            },
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "poi",
        "stylers": [
            {
                "saturation": -100
            },
            {
                "lightness": 51
            },
            {
                "visibility": "simplified"
            }
        ]
    },
    {
        "featureType": "road.highway",
        "stylers": [
            {
                "saturation": -100
            },
            {
                "visibility": "simplified"
            }
        ]
    },
    {
        "featureType": "road.arterial",
        "stylers": [
            {
                "saturation": -100
            },
            {
                "lightness": 30
            },
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "road.local",
        "stylers": [
            {
                "saturation": -100
            },
            {
                "lightness": 40
            },
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "transit",
        "stylers": [
            {
                "saturation": -100
            },
            {
                "visibility": "simplified"
            }
        ]
    },
    {
        "featureType": "administrative.province",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "water",
        "elementType": "labels",
        "stylers": [
            {
                "visibility": "on"
            },
            {
                "lightness": -25
            },
            {
                "saturation": -100
            }
        ]
    },
    {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
            {
                "hue": "#ffff00"
            },
            {
                "lightness": -25
            },
            {
                "saturation": -97
            }
        ]
    }
]


class App
  constructor: ->
    @first_lat_lon = {}
    @map_points = []
    @markers = []
    mapOptions = {
      zoom: 6,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      styles: window.map_styles
    }
    @map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions)
    for key, points of window.results
      @first_lat_lon = { lat: points[0].lat, lon: points[0].lng  } if @first_lat_lon = {}
      for point in points
        @add_point(point.lat, point.lng)
        @add_marker(point.lat, point.lng, point.title)
    @map.setCenter new google.maps.LatLng @first_lat_lon.lat, @first_lat_lon.lon
    @initialize()
    @draw_line()
    @hidden = true
    for marker in @markers
      marker.setVisible false
    $('.toggle').click (event)=>
      event.preventDefault()
      if @hidden
        for marker in @markers
          marker.setVisible true
        @hidden = false
      else
        for marker in @markers
          marker.setVisible false
        @hidden = true


  add_marker: (lat, lon, title)=>
    @markers.push new google.maps.Marker({
      map: @map
      position: new google.maps.LatLng(lat, lon) 
      title:title
      icon: 'https://dl.dropboxusercontent.com/u/29482823/lmi_pin.png'
    })

  draw_line: =>
    if window.location_to
      lines = [
        new google.maps.LatLng(location_to.lat, location_to.lng),
        new google.maps.LatLng(location_from.lat, location_from.lng)
      ]
      poly = new google.maps.Polyline({ map: @map, path: lines, strokeColor: '#4986E7' })

  add_point: (lat, lon)=>
    @map_points.push new google.maps.LatLng(lat, lon)

  initialize: =>
    @heatmap = new google.maps.visualization.HeatmapLayer({
      data: new google.maps.MVCArray(@map_points)
    })
    @heatmap.setMap(@map)

  changeGradient: ->
    gradient = [
      'rgba(0, 255, 255, 0)',
      'rgba(0, 255, 255, 1)',
      'rgba(0, 191, 255, 1)',
      'rgba(0, 127, 255, 1)',
      'rgba(0, 63, 255, 1)',
      'rgba(0, 0, 255, 1)',
      'rgba(0, 0, 223, 1)',
      'rgba(0, 0, 191, 1)',
      'rgba(0, 0, 159, 1)',
      'rgba(0, 0, 127, 1)',
      'rgba(63, 0, 91, 1)',
      'rgba(127, 0, 63, 1)',
      'rgba(191, 0, 31, 1)',
      'rgba(255, 0, 0, 1)'
    ]
    @heatmap.set('gradient', @heatmap.get('gradient') ? null : gradient)

  changeRadius: ->
    @heatmap.set('radius', @heatmap.get('radius') ? null : 20)

  changeOpacity: ->
    @heatmap.set('opacity', @heatmap.get('opacity') ? null : 0.2)

ready = ->
  if $('#map-canvas')[0]
    window.app = new App()
  if $('#nl-form')[0]
    nlform = new NLForm document.getElementById 'nl-form'
$(document).ready(ready)
$(document).on('page:load', ready)
