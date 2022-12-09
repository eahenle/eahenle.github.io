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
            label : d.active
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
    var h = 700
    // axis padding
    var padding = 70
    // toolitp image box edge length
    var image_size = 250

    // create the SVG
    var svg = d3.select("body")
        .append("svg")
        .attr("width", w)
        .attr("height", h)

    // set plot scaling
    var xMax = d3.max(molData, function(d) { return d.x })
    var xMin = d3.min(molData, function(d) { return d.x })
    var xScale = d3.scaleLinear()
        .domain([xMin, xMax]) 
        .range([padding, w - padding]) 

    var yMax = d3.max(molData, function(d) { return d.y })
    var yMin = d3.min(molData, function(d) { return d.y })
    var yScale = d3.scaleLinear()
        .domain([yMin, yMax])
        .range([h - padding, padding])

    // create axes
    var xAxis = d3.axisBottom(xScale)
        .ticks(5)

    var yAxis = d3.axisLeft(yScale)
        .ticks(5)

    // append axes to plot SVG
    svg.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(0," + (h - padding) + ")")
        .call(xAxis)

    svg.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(" + padding + ", 0)")
        .call(yAxis)

    // axis labels
    svg.append("text")
        .attr("class", "y label")
        .attr("text-anchor", "middle")
        .text("Latent Dimension 2")
        .attr("transform", "translate(10, " + (h / 2) + ") rotate (-90)")
        .attr("font-size", "14")
        .attr("font-family", "'Open Sans', sans-serif")

    svg.append("text")
        .attr("class", "x label")
        .attr("text-anchor", "middle")
        .text("Latent Dimension 1")
        .attr("transform", "translate(" + (w / 2) + ", " + (h - 10) + ")")
        .attr("font-size", "14")
        .attr("font-family", "'Open Sans', sans-serif")

    // Title
    svg.append("text")
        .attr("class", "Title")
        .attr("text-anchor", "middle")
        .text("Latent Molecular Space")
        .attr("transform", "translate(" + (w / 2) + ", " + (0.5 * padding) + ")")
        .attr("font-size", "20")
        .attr("font-family", "'Open Sans', sans-serif")

    // Create circles from molData
    svg.selectAll("circle")
        .data(molData)
        .enter()
        .append("circle")
        .attr("cx", function(d) { return xScale(d.x) })
        .attr("cy", function(d) { return yScale(d.y) })
        .attr("r", 5)
        .attr("fill", "steelblue")
        .on("mouseover", function(d) {
            tooltip.style("visibility", "visible")
        })
        .on("mousemove", function(d) {
            var string = "<img src=img/" + d.index + ".png style='height: " + image_size + "px; width: " + image_size + "px; object-fit: contain'>"
            return {
                image : tooltip.html(string)
                    .style("left", (d3.event.pageX + (d3.event.pageX > w / 2 ? -(10 + image_size) : 10)) + "px")
                    .style("top", (d3.event.pageY + (d3.event.pageY > h / 2 ? -(20 + image_size) : 20)) + "px")
                    .style("font-color", "white")
                    .transition()
                    .style("opacity", 0.9),
            }
        })
        .on("mouseout", function(d) {
            tooltip.style("visibility", "hidden")
        })

    // image tooltip style attributes
    var tooltip = d3.select("body")
        .append("div")
        .attr("width", 50 + 'px')
        .attr("width", 50 + 'px')
        .style("position", "absolute")
        .style("font-size", "10px")
        .style("z-index", "10")
        .style("visibility", "hidden")
}