set -e
echo "########################## WORK #########################################"
echo "running sanity checker for work"
docker compose exec -T webserver-work document_sanity_checker

echo "Exporting documents for work without zipping"
rm -rf data/work/export/backup
mkdir -p data/work/export/backup
docker compose exec -T webserver-work document_exporter -c ../export/backup

echo "Move to tmp directory"
rm -rf /tmp/backup_work
mv data/work/export/backup /tmp/backup_work

echo "Run rustic"
restic --password-file ./.backup_password --repo sftp:backup-storage:/backups/dms_work backup /tmp/backup_work

echo "Remove tmp backup"
rm -rf /tmp/backup_work

echo "Exporting documents for work with zipping"
rm -rf data/work/export/backup
mkdir -p data/work/export/backup
docker compose exec -T webserver-work document_exporter -c -z --passphrase $(cat ./.backup_password) ../export/backup
scp data/work/export/backup/*.zip backup-storage:/backups/dms_work_snapshots/
rm -rf data/work/export/backup

echo "########################## PRIVATE #########################################"
echo "running sanity checker for private"
docker compose exec -T webserver-private document_sanity_checker

echo "Exporting documents for private without zipping"
rm -rf data/private/export/backup
mkdir -p data/private/export/backup
docker compose exec -T webserver-private document_exporter -c ../export/backup

echo "Move to tmp directory"
rm -rf /tmp/backup_private
mv data/private/export/backup /tmp/backup_private

echo "Run rustic"
restic --password-file ./.backup_password --repo sftp:backup-storage:/backups/dms_private backup /tmp/backup_private

echo "Remove tmp backup"
rm -rf /tmp/backup_private

echo "Exporting documents for private with zipping"
rm -rf data/private/export/backup
mkdir -p data/private/export/backup
docker compose exec -T webserver-private document_exporter -c -z --passphrase $(cat ./.backup_password) ../export/backup
scp data/private/export/backup/*.zip backup-storage:/backups/dms_private_snapshots/
rm -rf data/private/export/backup
