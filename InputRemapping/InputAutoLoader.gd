extends Node

const SAVEPATH = "user://custom_inputs.txt"  # Directorio de guardado/cargado de archivos

var data_loaded = false                      # Si encontró archivo de guardado, será true
var loaded_actions : Dictionary = {}         # Acciones cargadas del archivo de guardado
var saved_actions  : Dictionary = {}         # Acciones a guardar en archivo de guardado
var savefile


func _ready():
	savefile  = File.new()
	# Buscar archivo de guardado existente
	if savefile.file_exists(SAVEPATH):
		print_debug("Archivo de inputs encontrado")
		# Abrir archivo encontrado
		var error = savefile.open(SAVEPATH, File.READ)
		if error == OK:
			# Leer archivo y cargar inputs
			var data = parse_json(savefile.get_as_text())
			load_inputs(data)
			data_loaded = true
			savefile.close()
		else:
			print_debug("Error: ", error)


# Carga los inputs desde un diccionario
func load_inputs(dict):
	# Iterar por el diccionario
	for key in dict.keys():
		var action_name = key
		var action_code = dict[key][0]
		var action_text = dict[key][1]
		# Dejar nombre de tecla en variable para labels
		loaded_actions[key] = action_text
		# Crear el evento para inputmap
		set_event(action_name, action_code)


# Crea evento para inputmap
func set_event(a_name, a_code):
	var new_event = InputEventKey.new()
	new_event.set_scancode(a_code)
	InputMap.action_add_event(a_name, new_event)


# Setear evento para guardar a archivo
func save_event(a_name, a_code, a_text):
	saved_actions[a_name] = [a_code, a_text]


# Limpiar diccionario de eventos a guardar
func clear_custom_keys():
	saved_actions = {}


# Guarda eventos en archivo
func save_events_to_file():
	print_debug("Saving dict...")
	savefile = File.new()
	var error = savefile.open(SAVEPATH, File.WRITE)
	if error == OK:
		savefile.store_string(JSON.print(saved_actions))
		savefile.close()
	else:
		print_debug("Error: ", error)

