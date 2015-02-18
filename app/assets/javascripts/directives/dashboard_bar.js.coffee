App.directive "dashboardBar", [ ->
  scope: {}
  restrict: "E"

  link: (scope, element, attributes) ->
    @maxCount = parseInt(attributes["maxCount"])
    @count = parseInt(attributes["count"])

    renderBar = ->
      svg = d3.select(element[0].parentNode)
      violationBarWidth = parseFloat(svg.style("width"))

      yScale = d3.scale.linear()
        .domain([0, @maxCount])
        .range([0, violationBarWidth])

      svg
        .attr("width", violationBarWidth)
        .append("rect")
        .attr(
          x: 0
          y: 0
          width: yScale(@count)
          height: 20
        )

    renderBar()
]
