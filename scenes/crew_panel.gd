extends Control

const MAX_SLOTS = 10
const CARD_HEIGHT = 80  # tweak this to taste

var _pending_remove_id:  String = ""
var _pending_role_id:    String = ""
var _pending_role_value: int    = -1
var isOpen = false

func _ready() -> void:
	var grid = $VBoxContainer/Grid
	grid.columns = 5
	CrewManager.crew_changed.connect(_rebuild)
	$VBoxContainer/Header/CloseButton.pressed.connect(_close)
	$ConfirmationDialog.confirmed.connect(_on_confirmed)
	
	hide()

# ── open / close ─────────────────────────────────────────────────────────────
func open() -> void:
	if !isOpen:
		isOpen = true
		$"../../Footer/MenuBar/CrewButton".disabled = true
		_rebuild()
		position.y = get_parent().size.y  # start at bottom of parent
		show()
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:y", 0.0, 0.35)

func _close() -> void:
	if isOpen:
		isOpen = false
		$"../../Footer/MenuBar/CrewButton".disabled = false
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "position:y", get_parent().size.y, 0.3)
		tween.tween_callback(hide)

# ── build ─────────────────────────────────────────────────────────────────────

func _rebuild() -> void:
	# Update header
	$VBoxContainer/Header/TitleLabel.text  = "Crew  %d / %d" % [CrewManager.members.size(), CrewManager.MAX_CREW]
	
	# Clear grid
	var grid = $VBoxContainer/Grid
	for child in grid.get_children():
		child.queue_free()

	# Fill member cards
	for member in CrewManager.members:
		grid.add_child(_build_card(member))

	# Fill empty slots
	var empty_count = CrewManager.MAX_CREW - CrewManager.members.size()
	for i in range(empty_count):
		grid.add_child(_build_empty_slot())

func _build_card(c: Character) -> PanelContainer:
	var panel = PanelContainer.new()
	var hbox  = HBoxContainer.new()
	panel.add_child(hbox)

	# Portrait placeholder
	var portrait = ColorRect.new()
	portrait.custom_minimum_size = Vector2(48, 48)
	portrait.color = Color(0.872, 0.797, 0.645, 1.0)
	hbox.add_child(portrait)

	# Info block
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info)

	var name_label = Label.new()
	name_label.text = c.name
	name_label.clip_text = true
	info.add_child(name_label)

	var bounty_label = Label.new()
	bounty_label.text = _format_bounty(c.bounty)
	info.add_child(bounty_label)
	bounty_label.clip_text = true

	var role_label = Label.new()
	role_label.text = Character.role_name(c.role)
	info.add_child(role_label)

	var skill_label = Label.new()
	skill_label.text = "Skill: %s" % Character.skill_name(c.skill)
	info.add_child(skill_label)

	# Action buttons
	var actions = VBoxContainer.new()
	hbox.add_child(actions)

	if not c.is_player:
		var remove_btn = Button.new()
		remove_btn.text = "✕"
		remove_btn.pressed.connect(_prompt_remove.bind(c.id, c.name))
		actions.add_child(remove_btn)
		
		var role_btn = Button.new()
		role_btn.text = "Role"
		role_btn.pressed.connect(_prompt_role_change.bind(c.id, c.role))
		actions.add_child(role_btn)

	return _wrap_card(panel)

func _build_empty_slot() -> PanelContainer:
	var panel = PanelContainer.new()
	var label = Label.new()
	label.text = "— Empty —"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	return _wrap_card(panel)

# ── role change ───────────────────────────────────────────────────────────────

func _prompt_role_change(member_id: String, current_role: Character.Role) -> void:
	var member = CrewManager.get_member(member_id)
	if member == null or member.available_roles.is_empty():
		return

	var popup = PopupMenu.new()
	add_child(popup)

	for role in member.available_roles:
		popup.add_item(Character.role_name(role), role)

	popup.id_pressed.connect(_on_role_selected.bind(member_id, current_role, popup))
	popup.popup(Rect2(get_global_mouse_position(), Vector2.ZERO))

func _on_role_selected(role_id: int, member_id: String, current_role: Character.Role, popup: PopupMenu) -> void:
	popup.queue_free()
	var new_role = role_id as Character.Role

	if new_role == current_role:
		return

	var holder = CrewManager.get_member_with_role(new_role)

	if holder != null and new_role != Character.Role.CREWMATE:
		# Warn about the swap
		_pending_role_id    = member_id
		_pending_role_value = role_id
		#var member = CrewManager.get_member(member_id)
		$ConfirmationDialog.dialog_text = "This will swap roles with %s. Continue?" % holder.name
		$ConfirmationDialog.show()
	else:
		CrewManager.assign_role(member_id, new_role)

# ── remove ────────────────────────────────────────────────────────────────────

func _prompt_remove(member_id: String, member_name: String) -> void:
	_pending_remove_id  = member_id
	_pending_role_id    = ""
	$ConfirmationDialog.dialog_text = "Remove %s from the crew?" % member_name
	$ConfirmationDialog.show()

# ── confirm dialog ────────────────────────────────────────────────────────────

func _on_confirmed() -> void:
	if _pending_remove_id != "":
		CrewManager.remove_member(_pending_remove_id)
		_pending_remove_id = ""
	elif _pending_role_id != "":
		CrewManager.assign_role(_pending_role_id, _pending_role_value as Character.Role)
		_pending_role_id    = ""
		_pending_role_value = -1

# ── helpers ───────────────────────────────────────────────────────────────────

func _format_bounty(value: int) -> String:
	# Format as e.g. "1,500,000,000"
	var s      = str(value)
	var result = ""
	var count  = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = " " + result
		result = s[i] + result
		count += 1
	return result + " B"

func _wrap_card(inner: Control) -> Control:
	var wrapper = Control.new()
	# Take exactly half the grid width, fixed height
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.size_flags_vertical   = Control.SIZE_FILL
	wrapper.custom_minimum_size   = Vector2(0, CARD_HEIGHT)
	inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrapper.add_child(inner)
	return wrapper
