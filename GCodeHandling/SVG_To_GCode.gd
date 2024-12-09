extends  Node

func svg_to_gcode(svg_path: String, output_path: String, feedrate: float = 1000.0):
	var svg_content = FileAccess.get_file_as_string(svg_path)
	if svg_content=="":
		print("Failed to read SVG file.")
		return
	
	var gcode = []
	gcode.append("G21")  # Set units to millimeters
	gcode.append("G90")  # Use absolute positioning
	
	# Regex to extract path data
	var regex = RegEx.new()
	regex.compile("d=\"([^\"]+)\"")
	var match = regex.search(svg_content)  # Perform the search
	
	if match:  # Ensure a match is found
		var path_data = match.get_string(1)  # Capture group 1 contains the path data
		var commands = path_data.split(" ")
		var i = 0
		while i < commands.size():
			var cmd = commands[i]
			if cmd == "M":  # Move to
				var x = commands[i + 1].to_float()
				var y = commands[i + 2].to_float()
				gcode.append("G00 X%f Y%f" % [x, y])  # Rapid move
				i += 3
			elif cmd == "L":  # Line to
				var x = commands[i + 1].to_float()
				var y = commands[i + 2].to_float()
				gcode.append("G01 X%f Y%f F%f" % [x, y, feedrate])  # Linear move with feedrate
				i += 3
			elif cmd == "Z":  # Close path
				gcode.append("G01 X0 Y0 F%f" % feedrate)  # Example: return to origin (customize as needed)
				i += 1
			else:
				i += 1  # Increment for unknown commands
	
	gcode.append("M05")  # Turn off laser (if used)
	
	# Write G-code to file
	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if file:
		file.store_string("\n".join(gcode))
		file.close()
		print("G-code saved to %s" % output_path)
	else:
		print("Failed to save G-code.")
