{
	"version": "0.2.0",
	"configurations": [
		{
			"name": "Windows",
			"type": "hxcpp",
			"request": "launch",
			"program": "${workspaceRoot}/export/windows/cpp/bin/${APPLICATION_FILE}.exe"
		},
		{
			"name": "Linux",
			"type": "hxcpp",
			"request": "launch",
			"program": "${workspaceRoot}/export/linux64/cpp/bin/${APPLICATION_FILE}"
		},
		{
			"name": "Mac",
			"type": "hxcpp",
			"request": "launch",
			"program": "${workspaceRoot}/export/mac64/cpp/bin/${APPLICATION_FILE}.app/Contents/MacOS/${APPLICATION_FILE}"
		}
	]
}