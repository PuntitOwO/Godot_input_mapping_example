extends Control

# Array para los colorRect de test
export (Array, NodePath) var tests_paths
# Array para los Labels
export (Array, NodePath) var labels_paths
# Array para los nombres de los eventos
export (Array, String)   var events_names = ["up", "down", "left", "right", "action"]
# Cantidad de eventos
var slots = events_names.size()
# Arrays de nodos que se llenarán con los seteados arriba
var tests_nodes = []
var labels_nodes = []

# Referencias a los botones
onready var button_set   = $HBoxContainer/VBoxContainer5/CenterContainer/Button
onready var button_def   = $HBoxContainer/VBoxContainer5/CenterContainer2/Button
onready var button_save  = $HBoxContainer/VBoxContainer5/CenterContainer3/Button


func _ready():
	# Obtener nos nodos de los arrays de nodepaths
	for path in tests_paths:
		tests_nodes.append(get_node_or_null(path))
	for path in labels_paths:
		labels_nodes.append(get_node_or_null(path))
	# Setear los colores de los rect a rojito (no es realmente necesario)
	for node in tests_nodes:
		node.color = Color.red
	# Setear las labels si se cargaron inputs de archivo
	if InputAutoLoader.data_loaded:
		if InputAutoLoader.loaded_actions.size() == slots:
			for i in range(slots):
				labels_nodes[i].text = InputAutoLoader.loaded_actions[events_names[i]]
	# Conectar las señales de los botones
	var _err1 = button_set.connect( "pressed", self, "set_custom_keys")
	var _err2 = button_def.connect( "pressed", self, "restore_custom_keys")
	var _err3 = button_save.connect("pressed", self, "save_custom_keys")

func _input(event):
	# Actualizar cada color rect a verde si se presiona, o rojo si se suelta
	for i in range(slots):
		if event.is_action_pressed(events_names[i]):
			tests_nodes[i].color = Color.green
		if event.is_action_released(events_names[i]):
			tests_nodes[i].color = Color.red

func set_custom_keys():
	# Soltar el focus del botón para que no se presione por accidente
	button_set.release_focus()
	# Reiniciar input map
	InputMap.load_from_globals()
	# Por cada input:
	for index in range(slots):
		# Hacer aparecer el mensaje y esperar input
		$KeySelectSplash.start(events_names[index])
		var scancode = yield($KeySelectSplash, "key_selected")
		
		# Configurar el nuevo input
		var new_event = InputEventKey.new()
		new_event.set_scancode(scancode)
		var key_name = new_event.as_text().to_upper()
		InputMap.action_add_event(events_names[index], new_event)
		InputAutoLoader.save_event(events_names[index], scancode, key_name)
		
		# Mostrar en pantalla la nueva tecla, y esperar un poco para evitar bugs
		labels_nodes[index].text = key_name
		yield(get_tree().create_timer(0.1), "timeout")


func restore_custom_keys():
	InputMap.load_from_globals()
	InputAutoLoader.clear_custom_keys()
	for index in range(slots):
		labels_nodes[index].text = "-"


func save_custom_keys():
	InputAutoLoader.save_events_to_file()
