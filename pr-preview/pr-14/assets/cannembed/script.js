// container for plot data
var molData = []

// load data from CSV
d3.csv(
    "data.csv", 
    function(d) {
        return {
            index : d.index,
            x : +d.x,
            y : +d.y,
            label : d.active, //! note: label is switched (active = 'false')
            compound_name : d.compound_name
        }
    }, 
    function(error, rows) {
        molData = rows
        createVisualization()
    }
)

// generate interactive plot
function createVisualization() {
    // image dimensions
    var w = 700
    var h = 400
    // axis padding
    var padding = 0.01
    var padding2 = 75
    // toolitp image box edge length
    var image_size = 200

    // create the plot SVG
    var plotdiv = d3.select("#plot")
    plotdiv.append("svg")
    plotdiv.attr("z-index", 1).style("display", "inline-block")
    // set plot size
    var plotsvg = plotdiv.select("svg")
    plotsvg.attr("width", w).attr("height", h)

    // set plot scaling
    var xMax = d3.max(molData, function(d) { return d.x }) + padding
    var xMin = d3.min(molData, function(d) { return d.x }) - padding
    var xScale = d3.scaleLinear()
        .domain([xMin, xMax]) 
        .range([padding2, w - padding2]) 

    var yMax = d3.max(molData, function(d) { return d.y }) + padding
    var yMin = d3.min(molData, function(d) { return d.y }) - padding
    var yScale = d3.scaleLinear()
        .domain([yMin, yMax])
        .range([h - padding2, padding2])

    // create axes
    var xAxis = d3.axisBottom(xScale).ticks(5)
    var yAxis = d3.axisLeft(yScale).ticks(5)

    // append axes to plot SVG
    plotsvg.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(0," + (h - padding2) + ")")
        .call(xAxis)

    plotsvg.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(" + padding2 + ", 0)")
        .call(yAxis)

    // axis labels
    plotsvg.append("text")
        .attr("class", "y label")
        .attr("text-anchor", "middle")
        .text("Latent Dimension 2")
        .attr("transform", "translate(25, " + (h / 2) + ") rotate (-90)")
        .attr("font-size", "18")
        .attr("font-family", "'Open Sans', sans-serif")

    plotsvg.append("text")
        .attr("class", "x label")
        .attr("text-anchor", "middle")
        .text("Latent Dimension 1")
        .attr("transform", "translate(" + (w / 2) + ", " + (h - 10) + ")")
        .attr("font-size", "18")
        .attr("font-family", "'Open Sans', sans-serif")

    // Title
    plotsvg.append("text")
        .attr("class", "Title")
        .attr("text-anchor", "middle")
        .text("Molecular Embedding")
        .attr("transform", "translate(" + (w / 2) + ", " + (0.5 * padding2) + ")")
        .attr("font-size", "24")
        .attr("font-family", "'Open Sans', sans-serif")

    // Create circles from molData
    plotsvg.selectAll("circle")
        .data(molData)
        .enter()
        .append("circle")
        .attr("cx", function(d) { return xScale(d.x) })
        .attr("cy", function(d) { return yScale(d.y) })
        .attr("r", 5)
        .attr("fill", function(d) { return d.label == "true" ? "black" : "green" })
        .on("mouseover", 
            function(d) {
                tooltip.style("visibility", "visible")
            }
        )
        .on("mousemove", 
            function(d) {
                var string = 
                    "<img src=img/" + d.index + ".png style='height: " + image_size + 
                    "px; width: " + image_size + "px'> <br>" + d.compound_name
                return {
                    image : tooltip.html(string)
                        .style(
                            "left", 
                            (d3.event.pageX + 
                                (d3.event.pageX > w / 2 ? -(10 + image_size) : 10)
                            ) + "px"
                        )
                        .style("top", 
                            (d3.event.pageY + 
                                (d3.event.pageY > h / 2 ? -(20 + image_size) : 20)
                            ) + "px"
                        )
                        .style("font-color", "white")
                        .style("background-color", "white")
                        .transition()
                        .style("opacity", 0.95)
                }
            }
        )
        .on("mouseout", function(d) { tooltip.style("visibility", "hidden") })

    // image tooltip style attributes
    var tooltip = d3.select("#plot")
        .append("div")
        .style("position", "absolute")

    // create legend SVG
    legenddiv = d3.select("#legend")
    legenddiv.attr("z-index", 2).style("display", "inline-block")
    legendsvg = legenddiv.append("svg")
    legendsvg.attr("width", 100).attr("height", h)

    // make legend dots
    legendsvg.append("circle")
        .attr("cx", 6)
        .attr("cy", h / 2 - 10)
        .attr("r", 6)
        .style("fill", "green")
    
    legendsvg.append("circle")
        .attr("cx", 6)
        .attr("cy", h / 2 + 10)
        .attr("r", 6)
        .style("fill", "black")

    // add legend text
    legendsvg.append("text")
        .attr("x", 20)
        .attr("y", h / 2 - 9)
        .text("bioactive")
        .style("font-size", "15px")
        .attr("alignment-baseline","middle")
        .attr("font-family", "'Open Sans', sans-serif")

    legendsvg.append("text")
        .attr("x", 20)
        .attr("y", h / 2 + 11)
        .text("inactive")
        .style("font-size", "15px")
        .attr("alignment-baseline","middle")
        .attr("font-family", "'Open Sans', sans-serif")
}
