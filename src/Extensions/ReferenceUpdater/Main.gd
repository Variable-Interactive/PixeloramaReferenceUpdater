extends Node

@onready var extension_api: Node  ## A variable for easy reference to the Api
var id: int
## This script acts as a setup for the extension
func _enter_tree() -> void:
	# NOTE: Use get_node_or_null("/root/ExtensionsApi") to access api.
	# NOTE: See https://www.oramainteractive.com/Pixelorama-Docs/extension_system/extension_api for
	# detailed documentation.
	extension_api = get_node_or_null("/root/ExtensionsApi")
	# |==== Your code goes here ====|
	id = extension_api.menu.add_menu_item(extension_api.menu.PROJECT, "Refresh References", self)
	# Check for changes when project is switched.
	extension_api.general.get_global().project_switched.connect(refresh_reference_images)
	# |=============================|


# Check for changes when application gains focus
func _notification(what: int) -> void:
	if not is_inside_tree():
		return
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			refresh_reference_images()


func menu_item_clicked():
	refresh_reference_images()


func refresh_reference_images():
	var update := false
	for ref_img in extension_api.project.current_project.reference_images:
		if FileAccess.file_exists(ref_img.image_path):
			var before_image: Image = ref_img.texture.get_image()
			ref_img.deserialize({"image_path": ref_img.image_path})
			var afterr_image: Image = ref_img.texture.get_image()
			if before_image.get_data() != afterr_image.get_data():
				update = true
	if update:
		extension_api.import.open_save_autoload().reference_image_imported.emit()


## Gets called when the extension is being disabled or uninstalled (while enabled).
func _exit_tree() -> void:
	# Remember to remove things that you added using this extension
	# Disconnect any signals and queue_free() any nodes that got added.
	extension_api.menu.remove_menu_item(extension_api.menu.PROJECT, id)
	extension_api.general.get_global().project_switched.disconnect(refresh_reference_images)
