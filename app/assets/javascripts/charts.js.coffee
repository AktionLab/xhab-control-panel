@init_fluid_temperature_chart = ->
  window.charts.temperature = new Highcharts.Chart {
    chart: {
      renderTo: 'chart-temperature',
      defaultSeriesType: 'area',
    },
    legend: false,
    title: false,
    #{
    #  text: 'Reservoir Temperature (°C)'
    #},
    xAxis: {
      type: 'datetime',
      minRange: 10,
      tickInterval: 100,
    },
    yAxis: {
      min: 70,
      max: 90,
      tickInterval: 10,
      minPadding: 0.1,
      title: {
        text: "Temp (°C)",
      }
    },
    series: [{
      name: "Temperature",
      data: [70,71,72,75,75,75,76,77,78,80,82,83,83,83,80,79,79,78,78],
    }]
  }

@init_fluid_ph_chart = ->
  window.charts.ph = new Highcharts.Chart {
    chart: {
      renderTo: 'chart-ph',
      defaultSeriesType: 'area',
    },
    legend: false,
    title: false,
    #{
    #  text: 'pH'
    #},
    xAxis: {
      type: 'datetime',
      minRange: 10,
      tickInterval: 100,
    },
    yAxis: {
      min: 4,
      max: 8,
      tickInterval: 1,
      minPadding: 0.1,
      title: {
        text: "pH",
      }
    },
    series: [{
      name: "pH",
      data: [6.2,6.2,6.1,6.1,6.1,6.1,6.0,6.0,6.0,6.1,6.1,6.1,6.2,6.2,6.3,6.3,6.3],
    }]
  }

@init_fluid_tds_chart = ->
  window.charts.tds = new Highcharts.Chart {
    chart: {
      renderTo: 'chart-tds',
      defaultSeriesType: 'area',
    },
    legend: false,
    title: false,
    xAxis: {
      type: 'datetime',
      minRange: 10,
      tickInterval: 100,
    },
    yAxis: {
      min: 0,
      max: 2000,
      tickInterval: 500,
      minPadding: 0.1,
      title: {
        text: "TDS (ppm)",
      }
    },
    series: [{
      name: "TDS",
      data: [1100,1100,1050,1050,1000,1000,1000,1000,1000,1000,1000,1000,1050,1050,1050,1100,1100],
    }]
  }

@init_moisture_chart = ->
  window.charts.moisture = new Highcharts.Chart {
    chart: {
      renderTo: 'chart-moisture',
      defaultSeriesType: 'area',
    },
    legend: false,
    title: false,
    #{
    #  text: 'Total Dissolved Solids'
    #},
    xAxis: {
      type: 'datetime',
      minRange: 10,
      tickInterval: 100,
    },
    yAxis: {
      min: 0,
      max: 100,
      tickInterval: 20,
      minPadding: 0.1,
      title: {
        text: "Moisture (%)",
      }
    },
    series: [{
      name: "TDS",
      data: [50,50,49,49,48,47,46,45,44,43,42,41,41,40,40,50,65,65,65,65,65,64,62],
    }]
  }

