#
## Name: Weather-Underground.Widget
## Destination App: Übersicht
## Created: 27.Mar.2018
## Author: Gert Massheimer
#
## === User Settings ===
## standard iconSet is "k" (options are: a - k)
iconSet = "a"
#
## max 10 days for forcast plus today!
numberOfDays = 10
#
## max number of weather alerts
numberOfAlerts = 1
#
## display as "day" or as "text" or as "icon" or as "iconplus"
#display = "day"        # Just the banner
#display = "text"       # The banner plus numberOfDays as detailed text
display = "icon"       # The banner plus 7 days as graph (with small icons)
#display = "iconplus"   # The banner plus "icon" plus 3 days of "text"
#
## location in degrees or state/town (GA/Duluth)
latitude = "34.0057742"
longitude = "-84.149144"
#
## your API-key from Weather-Underground (https://www.wunderground.com)
apiKey = "xxxxxxxxxxxxxxx"
#
## select you language
lang = 'de' # deutsch
#lang = 'en' # english
#
## select how the units are displayed
units = 'metric'   # Celsius and km
#units = 'imperial' # Fahrenheit and miles
#

#=== DO NOT EDIT AFTER THIS LINE unless you know what you're doing! ===
#======================================================================

if lang == 'de' then language = 'lang:DL/'
else language = ''

command: "curl -s 'http://api.wunderground.com/api/#{apiKey}/forecast10day/conditions/#{language}q/#{latitude},#{longitude}.json'"
# use this line when you live in US, only!
#command: "curl -s 'http://api.wunderground.com/api/#{apiKey}/forecast10day/conditions/#{language}q/GA/Duluth.json'"

refreshFrequency: '15m' # every 15 minutes

render: ->
  """
  <div class="weather">
    <table><tr><td>
      <div class="image"></div>
    </td><td>
    <div class="text-container">
      <div class="location"></div>
      <div class="conditions"></div>
      <div class="time"></div>
      <div class="wind"></div>
    </td></tr></table>
    <div class="forecast"></div>
  </div>
  """

update: (output, domEl) ->

  weatherData = JSON.parse(output)

  # --- show weather condition image
  if display == 'text' or display == 'day'
    icon  = '<img style="width:155%;height:155%" src="weather-underground.widget/images/' + iconSet + '/'
  if display == 'icon' or display == 'iconplus'
    icon  = '<img style="width:155%;height:155%" src="weather-underground.widget/images/k/'
  icon += weatherData.current_observation.icon
  icon += '.gif">'
  $(domEl).find('.image').html(icon)

  # --- show weather forecast location 
  location  = weatherData.current_observation.display_location.full
  location += '<span class="elevation">'
  location += ' ('
  location += weatherData.current_observation.display_location.elevation
  if lang == 'de'then location += ' m ü.NN)'
  else location += ' m ASL)'
  location += '</span>'
  $(domEl).find('.location').html(location)

  # --- show current weather conditions
  current  = weatherData.current_observation.temperature_string
  current += ' '
  current += weatherData.current_observation.weather
  $(domEl).find('.conditions').html(current)

  # --- show time of last update
  if lang == 'de' then areaCode = 'de-DE'
  else areaCode = 'en-US'
  time = new Date(weatherData.current_observation.observation_epoch * 1000).toLocaleDateString('areaCode', { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric', hour: 'numeric', minute: 'numeric' })
  $(domEl).find('.time').html(time)

  # --- show wind conditions
  if units == 'metric'
    currentWind = weatherData.current_observation.wind_kph
    windGust    = weatherData.current_observation.wind_gust_kph + ' km/h'
  else
    currentWind = weatherData.current_observation.wind_mph
    windGust    = weatherData.current_observation.wind_gust_mph + ' mph'
  if lang == 'de'
    wind  = 'Wind: '
    wind += currentWind
    wind += ' - '
    wind += windGust
    wind += ' aus ' + weatherData.current_observation.wind_dir
  else
    wind  = 'Winds '
    wind += weatherData.current_observation.wind_dir
    wind += ' at '
    wind += currentWind
    wind += ' - '
    wind += windGust
  $(domEl).find('.wind').html(wind)

  # --- generate weather alert message only if there is alert
  forecast = ''; d = 0; n = 0; dayMaxTemp = 0; weekMaxTemp = 0;
  if weatherData.hasOwnProperty('alerts')
    if numberOfAlerts < weatherData.alerts.length then maxAlerts = numberOfAlerts
    else maxAlerts = weatherData.alerts.length

    for i in [0..maxAlerts-1]
      # --- translate the alert type into human language
      switch weatherData.alerts[i].type
        when 'HUR'
          if lang == 'de' then alertType = 'Orkanwarnung'
          else alertType = 'Hurricane Local Statement'
        when 'TOR'
          if lang == 'de' then alertType = 'Tornadowarnung'
          else alertType = 'Tornado Warning'
        when 'TOW'
          if lang == 'de' then alertType = 'Tornado möglich'
          else alertType = 'Tornado Watch'
        when 'WRN'
          if lang == 'de' then alertType = 'Schwere Gewitterwarnung'
          else alertType = 'Severe Thunderstorm Warning'
        when 'SEW'
          if lang == 'de' then alertType = 'Schwere Gewitter möglich'
          else alertType = 'Severe Thunderstorm Watch'
        when 'WIN'
          if lang == 'de' then alertType = 'Mögliche Glätte'
          else alertType = 'Winter Weather Advisory'
        when 'FLO'
          if lang == 'de' then alertType = 'Hochwasserwarnung'
          else alertType = 'Flood Warning'
        when 'WAT'
          if lang == 'de' then alertType = 'Hochwasser möglich'
          else alertType = 'Flood Watch / Statement'
        when 'WND'
          if lang == 'de' then alertType = 'Starker Wind'
          else alertType = 'High Wind Advisory'
        when 'SVR'
          if lang == 'de' then alertType = 'Unwetter'
          else alertType = 'Severe Weather Statement'
        when 'HEA'
          if lang == 'de' then alertType = 'Extreme Hitze'
          else alertType = 'Heat Advisory'
        when 'FOG'
          if lang == 'de' then alertType = 'Dichter Nebel'
          else alertType = 'Dense Fog Advisory'
        when 'SPE'
          if lang == 'de' then alertType = 'Außergewöhnliches Wetter'
          else alertType = 'Special Weather Statement'
        when 'FIR'
          if lang == 'de' then alertType = 'Waldbrandgefahr'
          else alertType = 'Fire Weather Advisory'
        when 'VOL'
          if lang == 'de' then alertType = 'Vulkanische Aktivität'
          else alertType = 'Volcanic Activity Statement'
        when 'HWW'
          if lang == 'de' then alertType = 'Sehr starker Wind'
          else alertType = 'Hurricane Wind Warning'
        when 'REC'
          if lang == 'de' then alertType = 'Rekord erreicht'
          else alertType = 'Record Set'
        when 'REP'
          if lang == 'de' then alertType = 'Berichte'
          else alertType = 'Public Reports'
        when 'PUB'
          if lang == 'de' then alertType = 'Informationen'
          else alertType = 'Public Information Statement'
        else null

      # --- show the weather alert(s) 
      style = ' style="max-width:25rem;padding-bottom:1.5rem;"'
      forecast += '<table style="max-width:35rem;"><tr><td>'
      forecast += '<img src="weather-underground.widget/images/alert/alert.gif" alt="" />'
      forecast += '</td><td' + style + '>'
      forecast += '<span class="alert-type">'
      forecast += alertType
      forecast += '</span><br /><span class="alert-expires">'
      if lang == 'de' then forecast += ' Endet: '
      else forecast += ' Expires: '
      forecast += '</span><span class="alert-endtime">'
      forecast += weatherData.alerts[i].expires
      forecast += '</span><br /><span class="alert-desc">'
      forecast += weatherData.alerts[i].description + '</span>'
      forecast += '</td></tr></table>'
    $(domEl).find('.forecast').html(forecast)

  # --- generate the eight days weather columns
  else
    if numberOfDays > 10 then numberOfDays = 10
    if numberOfDays < 1 then numberOfDays = 1

    if display == 'icon' or display == 'iconplus'
      numberOfDays = 8

      if units == 'metric'
        forecast += '<table><tr>'
      else
        forecast += '<table class="table-bar"><tr>'

      # compute the hottest temperature of the forcast range to set the highest position of the dayBar
      for i in [0..numberOfDays-1]
        dayMaxTemp = Math.round(weatherData.forecast.simpleforecast.forecastday[i].high.celsius)
        if weekMaxTemp <= dayMaxTemp then weekMaxTemp = dayMaxTemp

      for i in [0..numberOfDays-1]
        if units == 'metric'
          dayMin = Math.round(weatherData.forecast.simpleforecast.forecastday[i].low.celsius)
          dayMax = Math.round(weatherData.forecast.simpleforecast.forecastday[i].high.celsius)
          pos = 75
        else
          dayMin      = Math.round(weatherData.forecast.simpleforecast.forecastday[i].low.fahrenheit)
          dayMax      = Math.round(weatherData.forecast.simpleforecast.forecastday[i].high.fahrenheit)
          pos = 180
        wDayShort   = weatherData.forecast.simpleforecast.forecastday[i].date.weekday_short

        dayIconName = weatherData.forecast.simpleforecast.forecastday[i].icon
        dayIcon     = 'weather-underground.widget/images/k/' + dayIconName + '.gif'

        wDayBar     = (weekMaxTemp - (dayMax * 2)) + pos # position of the bar from top
        dayBar      = (dayMax - dayMin + 5) * 2          # length / height of the bar
        
        # --- show the temperature columns
        forecast += '<td class="weekday-col"><div class="weekday-name">'
        if lang == 'de' then today = 'Heute'
        else today = 'Today'
        if i == 0 then forecast += today
        else forecast += wDayShort
        forecast += '</div><div class="weekday-icon"><img style="height:100%;width:100%;" src="'
        forecast += dayIcon
        forecast += '" alt="" /></div><div class="wdb" style="top:'
        forecast += wDayBar
        forecast += 'px;">'
        forecast += '<span class="temp-high" style="line-height:1.8">' + dayMax + '°</span>'
        forecast += '<br /><div class="db" style="height: '
        forecast += dayBar
        forecast += 'px;">'
        forecast += '</div><br />'
        forecast += '<span class="temp-low" style="line-height:1.4">' + dayMin + '°</span>'
        forecast += '</div></td>'
      forecast += '</tr></table>'
  
      if display is 'icon'
        $(domEl).find('.forecast').html(forecast)

    # --- generate the weather messages and put the condition icon in front
    if display == 'text' or display == 'iconplus'
      if display == 'iconplus' then numberOfDays = 3
      for i in [0..numberOfDays-1]

        switch i
          when 0 then d =  0; n =  1
          when 1 then d =  2; n =  3
          when 2 then d =  4; n =  5
          when 3 then d =  6; n =  7
          when 4 then d =  8; n =  9
          when 5 then d = 10; n = 11
          when 6 then d = 12; n = 13
          when 7 then d = 14; n = 15
          when 8 then d = 16; n = 17
          when 9 then d = 18; n = 19
          else null

        if units == 'metric'
          unit   = '°C'
          dayMin = weatherData.forecast.simpleforecast.forecastday[i].low.celsius
          dayMax = weatherData.forecast.simpleforecast.forecastday[i].high.celsius
          day    = weatherData.forecast.txt_forecast.forecastday[d].fcttext_metric
          night  = weatherData.forecast.txt_forecast.forecastday[n].fcttext_metric
        else
          unit   = '°F'
          dayMin = weatherData.forecast.simpleforecast.forecastday[i].low.fahrenheit
          dayMax = weatherData.forecast.simpleforecast.forecastday[i].high.fahrenheit
          day    = weatherData.forecast.txt_forecast.forecastday[d].fcttext
          night  = weatherData.forecast.txt_forecast.forecastday[n].fcttext

        wDayLong  = weatherData.forecast.simpleforecast.forecastday[i].date.weekday
        wDayShort = weatherData.forecast.simpleforecast.forecastday[i].date.weekday_short

        dayIconName   = weatherData.forecast.txt_forecast.forecastday[d].icon
        nightIconName = weatherData.forecast.txt_forecast.forecastday[n].icon

        dayIcon   = 'weather-underground.widget/images/' + iconSet + '/' + dayIconName + '.gif'
        nightIcon = 'weather-underground.widget/images/' + iconSet + '/' + nightIconName + '.gif'
        
        # --- show the weather messages
        if display != 'iconplus' then style = ' style="max-width:25rem;"'
        else style = ' style="max-width:19rem;"'
        forecast += '<table><tr><td' + style + '>'
        forecast += '<img src="' + dayIcon + '">'
        forecast += '</td><td' + style + '>'
        if i == 0
          if lang == 'de'
            forecast += '<span class="headline">Heute (' + wDayShort + ') tagsüber:</span> <span class="temp-low">'
          else
            forecast += '<span class="headline">Today (' + wDayShort + '):</span> <span class="temp-low">'
        else
          if lang == 'de'
            forecast += '<span class="headline">' + wDayLong + ' tagsüber:</span> <span class="temp-low">'
          else
            forecast += '<span class="headline">' + wDayLong + ' during the day:</span> <span class="temp-low">'
        forecast += dayMin + unit + '</span> - <span class="temp-high">' + dayMax + unit + '</span><br />' + day
        forecast += '</td></tr><tr><td' + style + '>'
        forecast += '<img src="' + nightIcon  + '">'
        forecast += '</td><td' + style + '>'
        if i is 0
          if lang == 'de'
            forecast += '<span class="headline">Heute (' + wDayShort + ') Nacht:</span><br />'+ night
          else
            forecast += '<span class="headline">Tonight (' + wDayShort + '):</span><br />'+ night
        else
          if lang == 'de'
            forecast += '<span class="headline">' + wDayLong + ' Nacht:</span><br />'+ night
          else
            forecast += '<span class="headline">' + wDayLong + ' Night:</span><br />'+ night
        forecast += '</td></tr></table>'

    if display is 'text' or 'iconplus'
      $(domEl).find('.forecast').html(forecast)

# --- style settings
style: """
  // position of the widget on the screen
  top 8%
  left 2%

  font-family system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto",
    "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue",
    sans-serif

  table
    border-spacing 0
    padding 0
    margin 0
    max-width 28rem

  th, td
    padding 0.1rem 0.5rem;
    margin 0

  td
    display table-cell
    max-width 16rem
    vertical-align middle

  .forecast
    color #c1e1f1
    font-weight 400
    font-size 0.7rem

  .weather
    border 1px solid #4f4f4f
    border-radius 20px
    background rgba(#000, 0.2)
    overflow-y scroll;
    padding 0.5rem

  .text-container
    padding 15px
    float right

  .image-container
    padding 0
    float left

  .location
    color #26b6d0
    font-weight 400
    font-size 1.25rem

  .elevation
    color #26b6d0
    font-weight 500
    font-size 0.75rem

  .conditions
    color #26b6d0
    font-weight bold
    font-size 1.25rem

  .time
    color #93cdda
    font-weight bold
    font-size 0.75rem
    padding-bottom 0.2rem

  .headline
    font-weight bolder
    font-size 0.8rem

  .temp-low
    color #5ebadc
    font-weight 500
    font-size 0.8rem

  .temp-high
    color #e22e4f
    font-weight 500
    font-size 0.8rem

  .image
    float left
    padding 5px 10px 0 10px

  .wind
    color #c1e1f1
    font-family $font
    float left
    font-size 0.75rem
    font-weight 400

  // Styles for display = icon

  .table-bar
    padding-bottom 2rem

  .weekday-col
    position relative
    color #fff
    height 10rem
    width 2rem
    white-space nowrap
    text-align center

  .weekday-name
    position absolute
    top 0
    height 1rem
    width 2rem
    font-weight 500

  .weekday-icon
    position absolute
    top 1rem
    height 2rem
    width 2rem

  .wdb
    position absolute
    height 4rem
    width 2rem

  .db
    background-color #fff
    display inline-block
    width 0.5rem
    padding 0.2rem
    border-radius 0.5rem
    border 2px solid #5ebadc

  // Styles for alerts

  .alert-type
    color #e22e4f
    font-weight 800
    font-size 1.4rem
    line-height 1.5

  .alert-expires
    color #57d960
    font-weight 600
    font-size 1.2rem
    line-height 1.3

  .alert-endtime
    color #e2ba2e
    font-weight 400
    font-size 0.9rem
    line-height 1.3

  .alert-desc
    color #c1e1f1
    font-weight bolder
    font-size 0.8rem
    line-height 1.5

"""
