extends Control

onready var input = $input
onready var output = $output
onready var command_handler = $command_handler

var commandHistoryLine = CommandHistory.history.size()


func _ready() -> void:
	input.grab_focus()

func _input(event) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_UP:
			goto_command_history(-1)
		if event.scancode == KEY_DOWN:
			goto_command_history(1)


func goto_command_history(offset) -> void:
	commandHistoryLine += offset
	commandHistoryLine = clamp(commandHistoryLine, 0, CommandHistory.history.size())
	if commandHistoryLine < CommandHistory.history.size() and CommandHistory.history.size() > 0:
		input.text = CommandHistory.history[commandHistoryLine]
		input.call_deferred("set_cursor_position", 99999999)

func process_command(text) -> void:
	var words = text.split(" ")
	words = Array(words)
	
	for i in range(words.count("")):
		words.erase("")
	
	if words.size() == 0:
		return
	
	CommandHistory.history.append(text)
	
	var command_word = words.pop_front()
	
	for c in command_handler.valid_commands:
		if c[0] == command_word:
			if words.size() != c[1].size():
				output_text(str("Failed to execute command \"", command_word, "\", expected ", c[1].size(), " parameter(s)"))
				return
			for i in range(words.size()):
				if !check_type(words[i], c[1][i]):
					output_text(str("Failed to execute command \"", command_word, "\", parameter ", (i + 1),
									"(\"", words[i], "\") is of the wrong type"))
					return
			output_text(command_handler.callv(command_word, words))
			return
	output_text(str("Command \"", command_word, "\" does not exist"))

func check_type(string, type) -> bool:
	if type == command_handler.ARG_INT:
		return string.is_valid_integer()
	if type == command_handler.ARG_FLOAT:
		return string.is_valid_float()
	if type == command_handler.ARG_BOOL:
		return (string == "true" or string == "false")
	if type == command_handler.ARG_STRING:
		return true
	return false

func output_text(text) -> void:
	output.text = str(output.text, "\n", text)
	output.set_v_scroll(99999999)


func _on_input_text_entered(new_text) -> void:
	input.clear()
	process_command(new_text)
	commandHistoryLine = CommandHistory.history.size()
