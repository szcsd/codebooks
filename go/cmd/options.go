package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/plugins/url_launcher"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(600, 800),
	flutter.AddPlugin(&url_launcher.UrlLauncherPlugin{}),
}
