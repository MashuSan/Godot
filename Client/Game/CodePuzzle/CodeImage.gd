extends TextureButton

var button_pos = -1

func _ready():
	pass

func _on_CodeImage_pressed():
	change_texture(GameManager.code_images_position)
	GameManager.change_code_texture(button_pos, GameManager.code_images_position)

func change_texture(texture_pos):
	self.texture_normal = GameManager.get_code_texture(texture_pos)
