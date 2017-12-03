package config

// Config application settings
type Config struct {
	Clickhouse struct {
		DSN string `default:"tcp://127.0.0.1:9000?debug=true"`
	}
}
