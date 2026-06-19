{
  config,
  pkgs,
  ...
}:
let
  makeBackup =
    {
      paths,
      calendar,
      tag,
      exclude ? [ ],
      backupPrepareCommand ? null,
      backupCleanupCommand ? null,
    }:
    {
      inherit
        paths
        exclude
        backupPrepareCommand
        backupCleanupCommand
        ;
      repositoryFile = config.sops.secrets."service/restic/repo".path;
      passwordFile = config.sops.secrets."service/restic/password".path;
      initialize = true;
      extraBackupArgs = [
        "--tag auto"
        "--tag"
        tag
        "--retry-lock 30m"
      ];
      timerConfig = {
        OnCalendar = calendar;
        Persistent = true;
      };
      pruneOpts = [
        "--tag auto"
        "--tag"
        tag
        "--keep-daily 30"
        "--keep-weekly 20"
        "--keep-monthly 12"
        "--retry-lock 30m"
      ];
    };
in
{
  services.restic.backups = {
    docker-homepage = makeBackup {
      paths = [ "/home/vhqkze/Developer/docker/homepage" ];
      calendar = "05:00";
      tag = "homepage";
    };
    docker-linkding = makeBackup {
      paths = [ "/home/vhqkze/Developer/docker/linkding" ];
      calendar = "05:05";
      tag = "linkding";
    };
    docker-memos = makeBackup {
      paths = [ "/home/vhqkze/Developer/docker/memos" ];
      calendar = "05:10";
      tag = "memos";
    };
    docker-plex = makeBackup {
      paths = [ "/home/vhqkze/Developer/docker/plex" ];
      calendar = "05:15";
      tag = "plex";
    };
    docker-ezbookkeeping = makeBackup {
      paths = [ "/home/vhqkze/Developer/docker/ezbookkeeping" ];
      calendar = "05:20";
      tag = "ezbookkeeping";
    };
    readeck = makeBackup {
      paths = [ "/var/lib/private/readeck" ];
      backupPrepareCommand = "systemctl stop readeck.service";
      backupCleanupCommand = "systemctl start readeck.service";
      calendar = "05:25";
      tag = "readeck";
    };
    grimmory = makeBackup {
      paths = [ "/home/vhqkze/Developer/docker/grimmory" ];
      backupPrepareCommand = ''
        ${pkgs.docker}/bin/docker exec grimmory_db sh -c 'exec /usr/bin/mariadb-dump -u root --password="$MYSQL_ROOT_PASSWORD" --all-databases --single-transaction --quick --routines --triggers --events' > /home/vhqkze/Developer/docker/grimmory/dump.sql
      '';
      backupCleanupCommand = "rm /home/vhqkze/Developer/docker/grimmory/dump.sql";
      calendar = "05:30";
      tag = "grimmory";
      # 恢复步骤
      # 先停止当前容器
      # sc-stop docker-grimmory_db.service
      # 删除 grimmory_db 挂载的文件
      # sudo rm -rf /home/vhqkze/Developer/docker/grimmory_db
      # 新生成一个干净的 grimmory_db 容器
      # sc-start docker-grimmory_db.service
      # 导出备份sql文件到当前目录
      # sudo restic-grimmory restore 46941cc7:/home/vhqkze/Developer/docker/grimmory --target ./ --include /dump.sql
      # 将备份sql文件复制到容器内 /tmp/backup.sql 位置
      # docker cp ./dump.sql grimmory_db:/tmp/backup.sql
      # 执行恢复，注意命令里的 $MYSQL_ROOT_PASSWORD 是容器内部的环境变量，这个环境变量需要存在
      # docker exec -it grimmory_db sh -c 'exec mariadb -u root --password="$MYSQL_ROOT_PASSWORD" -e "SOURCE /tmp/backup.sql;"'
      # 恢复完成，重启这个容器以删除备份sql文件（不删除也行）
      # sc-restart docker-grimmory_db.service
    };
  };
}
