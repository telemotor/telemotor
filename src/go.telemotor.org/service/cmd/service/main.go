package main

import (
	"os"

	"github.com/jinzhu/configor"
	"github.com/jmoiron/sqlx"
	_ "github.com/kshvakov/clickhouse"
	"go.telemotor.org/service/cmd/config"
)

func main() {
	var cfg = config.Config{}
	configor.Load(&cfg, os.Getenv("CONFIG_PATH"))
	connect, err := sqlx.Open("clickhouse", cfg.Clickhouse.DSN)
	if err != nil {
		panic(err)
	}
	err = connect.Ping()
	if err != nil {
		panic(err)
	}
}
