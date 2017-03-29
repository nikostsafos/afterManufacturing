(function () {

var contentWidth = document.getElementById('content').clientWidth;

var plotWidth;
  if (contentWidth >= 800) {plotWidth = contentWidth/4.05;} 
  else if (contentWidth >= 500) {plotWidth = contentWidth/3.05;}
  else { plotWidth = contentWidth/2.05; }

var plotHeight;
  if (contentWidth >= 800) {plotHeight = contentWidth/5.05;} 
  else if (contentWidth >= 500) {plotHeight = contentWidth/4.05;} 
  else { plotHeight = contentWidth/2.05; }

  var margin = {top: 20, right: 20, bottom: 20, left: 20},
      width = plotWidth - margin.left - margin.right,
      height = plotHeight - margin.top - margin.bottom;

  var x = d3.scaleLinear()
            .domain([1990,2016])
            .range([0, width]);

  var y = d3.scaleLinear()
            .domain([0, 12])
            .range([height, 0]);

  var area = d3.area()
               .x(function (d) {return x(d.Year);})
               .y1(function (d) {return y(d.Value)})
               .y0(y(0));

  var drawLine = d3.line()
               .x(function (d) {return x(d.Year);})
               .y(function (d) {return y(d.Value)});     

    d3.csv("data/employmentbySectorgrowth.csv", type, function(error, data) {
      if (error) throw error;

      var sectors = d3.nest()
          .key(function(d) { return d.Industry; })
          .entries(data);

      var svg = d3.select("#employmentbyTopEight").selectAll("svg")
          .data(sectors)
          .enter().append("svg")
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom)
          .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      svg.append('path')
         .attr('class', 'path')
         .attr("fill", "#c7eae5")
         .attr('d', function (sector) { return area(sector.values);});

      svg.append('path')
         .attr('class', 'line')
         .attr("fill", "None")
         .attr("stroke", '#01665e')
         .attr('stroke-width', 3)
         .attr('d', function (sector) { return drawLine(sector.values);});
            
      svg.append("text")
          .attr("x", width/2)
          .attr("y", 0)
          .attr('text-anchor', 'middle')
          .text(function(d) { return d.key; });

      // Append x axis 
      svg.append("g")
         .attr('class', 'xaxis')
         .attr("transform", "translate(0," + height + ")")
         .call(d3.axisBottom(x)
         .tickFormat(d3.format(".0f"))
         .tickValues([1990, 1995, 2000, 2005, 2010, 2016]));

      // Append y axis
      svg.append("g")
         .attr('class', 'yaxis')
         .call(d3.axisLeft(y)
         .ticks(6));

    });
      
    function type(d) {
      d.Industry = d.Industry;
      d.Year = +d.Year;
      d.Value = +d.Value;
      return d;
    }
})();
