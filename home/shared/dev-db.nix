{
  config,
  lib,
  pkgs,
  username,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin (
  let
    documentsDir = "${config.home.homeDirectory}/Documents";
    postgresDataDir = "${documentsDir}/postgres-data";
    postgresLogFile = "${documentsDir}/postgres.log";
    redisDataDir = "${documentsDir}/redis-data";
    redisLogFile = "${documentsDir}/redis.log";
    delaySeconds = 30;
    postgresql = pkgs.postgresql_17;

    startPostgres = pkgs.writeShellScript "postgres-delayed-start" ''
      set -euo pipefail
      /bin/wait4path ${lib.escapeShellArg documentsDir}
      /bin/sleep ${toString delaySeconds}
      if [ ! -f ${lib.escapeShellArg "${postgresDataDir}/PG_VERSION"} ]; then
        ${postgresql}/bin/initdb \
          -D ${lib.escapeShellArg postgresDataDir} \
          -U ${lib.escapeShellArg username} \
          -L ${postgresql}/share/postgresql
      fi
      exec ${postgresql}/bin/postgres \
        -D ${lib.escapeShellArg postgresDataDir} \
        -c listen_addresses=localhost \
        -p 5432
    '';

    startRedis = pkgs.writeShellScript "redis-delayed-start" ''
      set -euo pipefail
      /bin/wait4path ${lib.escapeShellArg documentsDir}
      /bin/sleep ${toString delaySeconds}
      mkdir -p ${lib.escapeShellArg redisDataDir}
      exec ${pkgs.redis}/bin/redis-server \
        --bind 127.0.0.1 \
        --port 6379 \
        --dir ${lib.escapeShellArg redisDataDir} \
        --logfile ${lib.escapeShellArg redisLogFile} \
        --daemonize no
    '';

    keepAlive = {
      Crashed = true;
      SuccessfulExit = false;
    };
  in
  {
    launchd.agents.postgres = {
      enable = true;
      config = {
        ProgramArguments = [ "${startPostgres}" ];
        RunAtLoad = true;
        KeepAlive = keepAlive;
        ProcessType = "Background";
        StandardOutPath = postgresLogFile;
        StandardErrorPath = postgresLogFile;
      };
    };

    launchd.agents.redis = {
      enable = true;
      config = {
        ProgramArguments = [ "${startRedis}" ];
        RunAtLoad = true;
        KeepAlive = keepAlive;
        ProcessType = "Background";
        StandardOutPath = redisLogFile;
        StandardErrorPath = redisLogFile;
      };
    };
  }
)
