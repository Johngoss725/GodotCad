extends Node

func save_svg(points: Array, filename: String = "res://Data/output.svg"):
	# Define the SVG header
	var svg_header = '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="500" height="500">'
	
	# Create the SVG path
	var svg_path = '<path d="'
	for i in points.size():
		var x = points[i].x
		var y = points[i].z
		if i == 0:
			svg_path += 'M %d %d ' % [x, y]  # Move to the first point
		else:
			svg_path += 'L %d %d ' % [x, y]  # Draw lines to subsequent points
	svg_path += '" fill="none" stroke="black" />'
	
	# Close the SVG
	var svg_footer = '</svg>'
	
	# Combine the parts
	var svg_content = svg_header + svg_path + svg_footer
	
	# Save to file
	var file = FileAccess.open(filename, FileAccess.WRITE)
	if file:
		file.store_string(svg_content)
		file.close()
		print("SVG saved to %s" % filename)
