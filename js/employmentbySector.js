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

  var margin = {top: 30, right: 20, bottom: 20, left: 20},
      width = plotWidth - margin.left - margin.right,
      height = plotHeight - margin.top - margin.bottom;

  var x = d3.scaleBand()
            .domain(['1940', '1960', '1980', '2000', '2016'])
            .range([0, width])
            .padding(0.1);

  var y = d3.scaleLinear()
            .domain([0, 25])
            .range([height, 0]);

  var color = d3.scaleOrdinal()
                .domain(['1940', '1960', '1980', '2000', '2016'])
                .range(['#8c510a', '#d8b365', '#c7eae5', '#5ab4ac', '#01665e']);

    d3.csv("data/employmentbySector.csv", type, function(error, data) {
    // d3.csv("data/data.csv", type, function(error, data) {
      if (error) throw error;

      var sectors = d3.nest()
          .key(function(d) { return d.Sector; })
          .entries(data);

      var svg = d3.select("#employmentbySector").selectAll("svg")
          .data(sectors)
          .enter().append("svg")
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom)
          .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      svg.selectAll('bar')
         .data(function(d) {return d.values;})
         .enter()
         .append('rect')
         .attr('class', 'bar')
         .attr("x", function(d) { return x(d.Year); })
         .attr("y", function(d) { return y(d.Value); })
         .attr("width", x.bandwidth())
         .attr("height", function(d) { return height - y(d.Value); })
         .attr("fill", function(d) {return color(d.Year)});
            
      svg.append("text")
          .attr("x", width/2)
          .attr("y", -5)
          .attr('text-anchor', 'middle')
          .text(function(d) { return d.key; });

      // Append x axis 
      svg.append("g")
         .attr('class', 'xaxis')
         .attr("transform", "translate(0," + height + ")")
         .call(d3.axisBottom(x)
         .tickFormat(d3.format(".0f"))
         .tickValues([1940, 1960, 1980, 2000, 2016]));

      // Append y axis
      svg.append("g")
         .attr('class', 'yaxis')
         .call(d3.axisLeft(y)
         .ticks(6));

    })
      
    function type(d) {
      d.Sector = d.Sector;
      d.Year = d.Year;
      d.Value = +d.Value;
      return d;
    }
})();