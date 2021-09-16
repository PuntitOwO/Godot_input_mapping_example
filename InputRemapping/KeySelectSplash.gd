extends Panel

# Señal enviada al detectar un input
signal key_selected(args)

# Desactivar el procesado de inputs en ready
func _ready():
	set_process_input(false)

# Aparecer en pantalla y procesar inputs
func start(btn_name):
	$CenterContainer/HBoxContainer/Button.text = btn_name
	show()
	set_process_input(true)

# Desaparecer y dejar de procesar inputs
func stop():
	hide()
	$CenterContainer/HBoxContainer/Button.text = ""
	set_process_input(false)

# Procesar inputs
func _input(event):
	if not event.is_pressed():
		return
	var key = event.scancode
	emit_signal("key_selected", key)
	stop()
