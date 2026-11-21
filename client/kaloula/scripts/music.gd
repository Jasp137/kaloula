extends Node
## Background music (autoload "Music"). Lives outside the scenes, so a track keeps
## playing across scene changes, e.g. from the main menu into a match.

var _player := AudioStreamPlayer.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep playing while the game is paused
	_player.bus = GameSettings.MUSIC_BUS
	add_child(_player)


## Loop `stream`. A track that's already playing carries on, so every scene can ask for its music.
func play(stream: AudioStream) -> void:
	assert(stream != null, "Music.play needs a stream")
	if _player.stream == stream and _player.playing:
		return
	if stream is AudioStreamMP3:
		stream.loop = true
	_player.stream = stream
	_player.play()
